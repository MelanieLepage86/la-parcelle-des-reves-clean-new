class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue JSON::ParserError => e
      Rails.logger.error("Webhook JSON parsing error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Webhook signature verification error: #{e.message}")
      return head :bad_request
    end

    Rails.logger.info("📩 Webhook reçu : #{event['type']}")

    case event['type']
    when 'payment_intent.succeeded'
      handle_successful_payment(event['data']['object'])
    when 'charge.succeeded'
      Rails.logger.info("📌 charge.succeeded reçu")
    when 'transfer.created'
      Rails.logger.info("🔁 transfer.created reçu : #{event['data']['object']['id']}")
    when 'transfer.paid'
      handle_transfer_paid(event['data']['object'])
    else
      Rails.logger.info("Webhook non traité : #{event['type']}")
    end

    render json: { status: 'received' }, status: :ok
  end

  private

  def handle_successful_payment(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent['id'])

    unless order
      Rails.logger.warn("⚠️ Aucun Order trouvé pour payment_intent #{payment_intent['id']}")
      return
    end

    return if order.payment_confirmed?
    return unless order.status == 'pending'

    transfer_group = "order_#{order.id}"
    Rails.logger.info("💰 Paiement reçu pour commande ##{order.id} – création des transferts Stripe…")

    all_transfers_successful = true

    order.order_items.includes(:artwork).each do |item|
      artist = item.artwork.user
      unless artist.stripe_account_id.present?
        Rails.logger.warn("⚠️ Artwork ##{item.artwork.id} sans compte Stripe pour l’artiste ##{artist.id}")
        all_transfers_successful = false
        next
      end

      amount = (item.unit_price.to_f * 100).to_i

      begin
        Stripe::Transfer.create(
          amount: amount,
          currency: 'eur',
          destination: artist.stripe_account_id,
          transfer_group: transfer_group,
          description: "Vente œuvre ##{item.artwork.id} (commande ##{order.id})",
          metadata: {
            order_id: order.id,
            artist_id: artist.id,
            artwork_id: item.artwork.id
          }
        ).tap do |t|
          Rails.logger.info("✅ Transfert de #{amount} centimes à l’artiste ##{artist.id} – #{t.id}")
        end
      rescue => e
        Rails.logger.error("❌ Échec du transfert pour l’artiste ##{artist.id} – #{e.message}")
        all_transfers_successful = false
      end
    end


    most_expensive_item = order.order_items.max_by(&:unit_price)
    if most_expensive_item&.artwork&.user&.stripe_account_id
      shipping_amount = (order.shipping_cost.to_f * 100).to_i
      begin
        Stripe::Transfer.create(
          amount: shipping_amount,
          currency: 'eur',
          destination: most_expensive_item.artwork.user.stripe_account_id,
          transfer_group: transfer_group,
          description: "Frais de port – commande ##{order.id}",
          metadata: {
            order_id: order.id,
            artist_id: most_expensive_item.artwork.user.id,
            shipping: true
          }
        ).tap do |t|
          Rails.logger.info("✅ Transfert frais de port #{shipping_amount} centimes – #{t.id}")
        end
      rescue => e
        Rails.logger.error("❌ Échec transfert frais de port – #{e.message}")
        all_transfers_successful = false
      end
    end

    if all_transfers_successful
      order.update!(status: 'payment_confirmed')
      Rails.logger.info("✅ Commande ##{order.id} marquée comme payée")
      OrderMailer.confirmation_email(order).deliver_later
      Rails.logger.info("📧 Mail de confirmation envoyé pour la commande ##{order.id}")
    else
      Rails.logger.warn("⚠️ Certains transferts ont échoué pour la commande ##{order.id}, statut non confirmé")
    end
  end

  def handle_transfer_paid(transfer)
    Rails.logger.info("💸 Transfert payé confirmé : #{transfer['id']}")
  end
end
