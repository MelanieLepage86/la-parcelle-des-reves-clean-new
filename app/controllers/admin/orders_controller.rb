class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_artist!

  def index
    @orders = Order.includes(order_items: :artwork).order(created_at: :desc)
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(status: params[:order][:status])
      redirect_to admin_dashboard_path, notice: "Statut mis à jour"
    else
      redirect_to admin_dashboard_path, alert: "Erreur lors de la mise à jour du statut"
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to admin_dashboard_path, notice: "Commande supprimée avec succès."
  end

  private

  def ensure_artist!
    redirect_to root_path, alert: "Accès réservé aux artistes" unless current_user&.admin?
  end
end

