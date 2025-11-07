class WebhooksController < ApplicationController
  # Stripe ne peut pas envoyer de CSRF token, donc on désactive pour cette action :
  skip_before_action :verify_authenticity_token, only: [:stripe]

  def stripe
    # Log complet des headers
    Rails.logger.info "🔍 Headers reçus : #{request.headers.env.select { |k,_v| k.start_with?('HTTP_') || k == 'CONTENT_TYPE' }}"

    sig_header = request.headers['Stripe-Signature']
    Rails.logger.info "🔍 Stripe-Signature header: #{sig_header.inspect}"

    payload = request.body.read
    Rails.logger.info "🔍 Payload reçu (preview 500 chars) : #{payload[0..500]}"

    begin
      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        ENV['STRIPE_WEBHOOK_SECRET']
      )

    Rails.logger.info "✅ Webhook Stripe vérifié avec succès : #{event.type}"

    Rails.logger.info("📩 Webhook Stripe reçu : #{event['type']}")
    Rails.logger.info("🔍 Secret utilisé (début): #{ENV['STRIPE_WEBHOOK_SECRET'][0..5]}...")

    # --- 🔹 Traitement des événements ---
    case event['type']
    when 'payment_intent.succeeded'
      handle_successful_payment(event['data']['object'])
    when 'charge.succeeded'
      Rails.logger.info("📌 charge.succeeded reçu (paiement confirmé côté carte)")
    when 'transfer.created'
      handle_transfer_created(event['data']['object'])
    else
      Rails.logger.info("ℹ️ Webhook non géré : #{event['type']}")
    end

     head :ok
    rescue JSON::ParserError => e
      Rails.logger.error "❌ Payload invalide : #{e.message}"
      head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "❌ Erreur vérification signature Stripe : #{e.message}"
      head :bad_request
    end
  end

  private

  # --- 🔹 Paiement réussi ---
  def handle_successful_payment(payment_intent)
    Rails.logger.info("💰 Handling PaymentIntent #{payment_intent['id']} - amount: #{payment_intent['amount_received']} - metadata: #{payment_intent['metadata'].inspect}")

    order = Order.find_by(stripe_payment_intent_id: payment_intent['id'])

    unless order
      Rails.logger.warn("⚠️ Aucun Order trouvé pour payment_intent #{payment_intent['id']}")
      return
    end

    return Rails.logger.info("ℹ️ Paiement déjà confirmé pour la commande ##{order.id}") if order.payment_confirmed?
    return Rails.logger.warn("⚠️ Order ##{order.id} dans un état inattendu (#{order.status})") unless order.status == 'pending'

    transfer_group = "order_#{order.id}"
    Rails.logger.info("💰 Paiement reçu pour commande ##{order.id} – création des transferts Stripe…")
    Rails.logger.info("➡️ Nombre d'items dans la commande : #{order.order_items.count}")

    # --- 🔸 Transferts pour chaque artiste ---
    order.order_items.includes(:artwork).each do |item|
      artist = item.artwork.user
      amount = (item.unit_price.to_f * 100).to_i

      next if artist.stripe_account_id.blank?
      next if amount <= 0

      begin
        transfer = Stripe::Transfer.create(
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
        )
        Rails.logger.info("✅ Transfert #{transfer.id} créé (#{amount} centimes) pour artiste ##{artist.id}")
      rescue Stripe::StripeError => e
        Rails.logger.error("❌ Échec du transfert pour artiste ##{artist.id} : #{e.message}")
      end
    end

    # --- 🔸 Transfert frais de port ---
    most_expensive_item = order.order_items.max_by(&:unit_price)
    if most_expensive_item
      artist = most_expensive_item.artwork.user
      shipping_amount = (order.shipping_cost.to_f * 100).to_i

      if shipping_amount > 0 && artist&.stripe_account_id.present?
        begin
          _transfer = Stripe::Transfer.create(
            amount: shipping_amount,
            currency: 'eur',
            destination: artist.stripe_account_id,
            transfer_group: transfer_group,
            description: "Frais de port – commande ##{order.id}",
            metadata: {
              order_id: order.id,
              artist_id: artist.id,
              shipping: true
            }
          )
          Rails.logger.info("✅ Transfert frais de port (#{shipping_amount} centimes) → artiste ##{artist.id}")
        rescue Stripe::StripeError => e
          Rails.logger.error("❌ Erreur transfert frais de port : #{e.message}")
        end
      end
    end

    # --- 🔸 Finalisation commande ---
    order.update!(status: 'payment_confirmed')
    Rails.logger.info("✅ Commande ##{order.id} marquée comme payée")
    OrderMailer.confirmation_email(order).deliver_now
    Rails.logger.info("📧 Mail de confirmation envoyé pour commande ##{order.id}")
    OrderMailer.notify_artist(order).deliver_now
    Rails.logger.info("🎨 Mail envoyé à laparcelledesreves.art@gmail.com")
  rescue => e
    Rails.logger.error("💥 Erreur handle_successful_payment: #{e.message}")
  end

  # --- 🔹 Transfert confirmé ---
  def handle_transfer_created(transfer)
    Rails.logger.info("💸 Transfert créé : #{transfer['id']} - montant: #{transfer['amount']} #{transfer['currency']}")
  end
end
