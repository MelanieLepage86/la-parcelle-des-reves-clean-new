class OrdersController < ApplicationController
  def create
    @artwork = Artwork.find(params[:artwork_id])
    email = params[:order][:email]

    ActiveRecord::Base.transaction do
      @order = Order.create!(
        email: email,
        total_amount: @artwork.price,
        delivery_method: params[:order][:delivery_method],
        country: params[:order][:country],
        status: 'pending'
      )

      @order.order_items.create!(
        artwork: @artwork,
        quantity: 1,
        unit_price: @artwork.price
      )

      @artwork.update!(sold: true)

      shipping_cost = ShippingCalculator.new(@order).calculate
      @order.update!(shipping_cost: shipping_cost)
    end

    redirect_to order_path(@order)
  rescue ActiveRecord::RecordInvalid => e
    logger.error "Order creation failed: #{e.message}"
    flash[:alert] = "Une erreur est survenue : #{e.message}"
    redirect_to artwork_path(@artwork)
  end

  def show
    @order = Order.find(params[:id])
  end

  def cancel
    @order = Order.find(params[:id])

    if @order.status == "pending"
      @order.order_items.each do |item|
        item.artwork.update!(sold: false)
      end

      @order.destroy
      session[:cart] = []
      redirect_to root_path, notice: "Commande annulée avec succès."
    else
      redirect_to order_path(@order), alert: "Impossible d'annuler une commande déjà payée ou traitée."
    end
  end
end
