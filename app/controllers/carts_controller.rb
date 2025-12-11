class CartsController < ApplicationController
  def add
    session[:cart] ||= []
    artwork_id = params[:artwork_id].to_i

    artwork = Artwork.find(artwork_id)

    quantity = if artwork.reproducible?
                 params[:quantity].to_i
               else
                 1
               end

    quantity = 1 if quantity < 1

    quantity.times do
      session[:cart] << artwork_id
    end

    redirect_to cart_path, notice: "Ajouté au panier"
  end

  def show
    @artworks = Artwork.where(id: session[:cart]).with_attached_images
    @cart_count = session[:cart]&.size || 0

    # Calcul du total du panier en tenant compte des quantités
    @cart_total = 0
    @artworks.each do |art|
      quantity_in_cart = session[:cart].count(art.id)
      @cart_total += art.price * quantity_in_cart
    end
  end

  def checkout_info
    if session[:cart].blank?
      redirect_to cart_path, alert: "Votre panier est vide."
      return
    end

    @order = Order.new
  end

  def checkout_create_order
    if session[:cart].blank?
      redirect_to cart_path, alert: "Votre panier est vide."
      return
    end

    artworks = Artwork.where(id: session[:cart])
    artworks_total = artworks.sum { |art| art.price * session[:cart].count(art.id) }

    # Vérifie si certaines œuvres sont vendues et non reproductibles
    if artworks.any? { |a| a.sold && !a.reproducible? }
      redirect_to cart_path, alert: "Certaines œuvres dans votre panier ont déjà été vendues."
      return
    end

    @order = Order.new(order_params)
    @order.status = 'pending'

    ActiveRecord::Base.transaction do
      @order.save!

      artworks.each do |art|
        quantity_in_cart = session[:cart].count(art.id)
        @order.order_items.create!(
          artwork: art,
          quantity: quantity_in_cart,  # Utilise la quantité dans le panier
          unit_price: art.price
        )
        art.update!(sold: true) unless art.reproducible?  # Si non reproductible, on marque l'œuvre comme vendue
      end

      shipping_cost = ShippingCalculator.new(@order).calculate
      @order.update!(
        shipping_cost: shipping_cost,
        total_amount: artworks_total + shipping_cost
      )
    end

    session[:cart] = []  # Vide le panier après la création de la commande
    redirect_to checkout_payment_cart_path(id: @order.id)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "=== ERREURS VALIDATION ORDER ==="
    Rails.logger.error "Exception: #{e.message}"
    Rails.logger.error @order.errors.full_messages.join(", ")
    render :checkout_info, status: :unprocessable_entity
  end

  def checkout_payment
    @order = Order.find(params[:id])

    if @order.stripe_payment_intent_id.blank?
      payment_intent = Stripe::PaymentIntent.create(
        amount: (@order.total_amount * 100).to_i,
        currency: 'eur',
        automatic_payment_methods: { enabled: true },
        metadata: { order_id: @order.id },
        transfer_group: "order_#{@order.id}"
      )
      @order.update!(stripe_payment_intent_id: payment_intent.id)
    end

    @stripe_public_key = ENV['STRIPE_PUBLISHABLE_KEY']

    render :checkout_payment, status: :ok
  end

  def remove
    session[:cart] ||= []
    artwork_id = params[:artwork_id].to_i
    session[:cart].delete(artwork_id)
    redirect_to cart_path, notice: "Article retiré du panier"
  end

  def payment_intent
    order = Order.find(params[:id])

    if order.stripe_payment_intent_id.present?
      payment_intent = Stripe::PaymentIntent.retrieve(order.stripe_payment_intent_id)
    else
      payment_intent = Stripe::PaymentIntent.create(
        amount: (order.total_amount * 100).to_i,
        currency: 'eur',
        automatic_payment_methods: { enabled: true },
        metadata: { order_id: order.id },
        transfer_group: "order_#{order.id}",
        capture_method: 'automatic'
      )
      order.update!(stripe_payment_intent_id: payment_intent.id)
    end

    render json: { client_secret: payment_intent.client_secret }
  end

  private

  def order_params
    params.require(:order).permit(
      :delivery_method, :first_name, :last_name, :email, :phone,
      :address_line, :postal_code, :city, :country
    )
  end
end
