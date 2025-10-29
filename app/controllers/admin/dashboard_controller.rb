class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_admin

  def index
    @artworks = current_user.artworks
    @artworks = @artworks.where(category: params[:category]) if params[:category].present?

    @visites_aujourdhui = Ahoy::Visit.where("started_at >= ?", Time.zone.now.beginning_of_day)
    @visites_aujourdhui ||= []

    @visites_semaine = Ahoy::Visit.where("started_at >= ?", Time.zone.now.beginning_of_week)
    @visites_semaine ||= []

    @visites_mois = Ahoy::Visit.where("started_at >= ?", Time.zone.now.beginning_of_month)
    @visites_mois ||= []

    @source_traffics = Ahoy::Visit.group(:utm_source).count
    @source_traffics ||= {}

    @localisation_visites = Ahoy::Visit.group(:city).count
    @localisation_visites ||= []

    @page_images = PageImage.all
    @default_image_names = [
      "acceuil", "Boutique-Curiosités", "Boutique-Peinture", "Boutique-Cyano",
      "Portfolio-Nature", "Portfolio-Photomanip", "Portfolio-Portrait",
      "Portfolio-Reportage", "Presta-Cyano", "Presta-Peinture", "Presta-Photo",
      "Catherine", "Amelie"
    ]

    @orders = Order.includes(order_items: :artwork).order(created_at: :desc)
    @news_items = NewsItem.order(created_at: :desc)
  end

  def new_image
    @image_names = [
      "acceuil", "Boutique-Curiosités", "Boutique-Peinture", "Boutique-Cyano",
      "Portfolio-Nature", "Portfolio-Photomanip", "Portfolio-Portrait",
      "Portfolio-Reportage", "Presta-Cyano", "Presta-Peinture", "Presta-Photo",
      "Catherine", "Amelie"
    ]
    @page_image = PageImage.new
  end

  def create_image
    @page_image = PageImage.find_or_initialize_by(name: page_image_params[:name])

    if @page_image.update(page_image_params)
      redirect_to admin_dashboard_path, notice: "Image mise à jour avec succès."
    else
      render :new_image
    end
  end

  def newsletter_subscribers
    @subscribers = Subscriber.order(created_at: :desc)
  end

  private

  def check_if_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Accès réservé à l'administration."
    end
  end

  def page_image_params
    params.require(:page_image).permit(:name, :image)
  end
end
