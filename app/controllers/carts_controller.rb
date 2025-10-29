class CartsController < ApplicationController
  def add
    session[:cart] ||= []
    artwork_id = params[:artwork_id].to_i
    session[:cart] << artwork_id unless session[:cart].include?(artwork_id)
    redirect_to cart_path, notice: "Ajouté au panier"
  end

  def show
    @artworks = Artwork.where(id: session[:cart]).with_attached_images
    @cart_count = session[:cart]&.size || 0
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
    artworks_total = artworks.sum(&:price)

    if artworks.any?(&:sold)
      redirect_to cart_path, alert: "Certaines œuvres dans votre panier ont déjà été vendues."
      return
    end

    @order = Order.new(order_params)
    @order.status = 'pending'

    ActiveRecord::Base.transaction do
      @order.save!

      artworks.each do |art|
        @order.order_items.create!(
          artwork: art,
          quantity: 1,
          unit_price: art.price
        )
        art.update!(sold: true)
      end

      shipping_cost = ShippingCalculator.new(@order).calculate
      @order.update!(
        shipping_cost: shipping_cost,
        total_amount: artworks_total + shipping_cost
      )
    end

    session[:cart] = []
    redirect_to checkout_payment_cart_path(@order)
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

    @stripe_public_key = ENV['STRIPE_PUBLISHABLE_KEY'] || ENV['STRIPE_TEST_PUBLISHABLE_KEY']
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
