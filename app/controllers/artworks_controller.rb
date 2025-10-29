class ArtworksController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :portfolio, :boutique, :prestations, :sub_category]
  before_action :set_artwork, only: [:show, :edit, :update, :destroy]
  before_action :verify_owner!, only: [:edit, :update, :destroy]

  def index
    @artworks = Artwork.published
  end

  def show
    @artwork = Artwork.find(params[:id])
    @sub_category = @artwork.sub_category
  end

  def portfolio
    @artworks = Artwork.published.where(category: 'portfolio')
  end

  def boutique
    @artworks = Artwork.published.where(category: 'boutique')
  end

  def prestations
    @artworks = Artwork.published.where(category: 'prestation')
  end

  def sub_category
    @category = params[:category]
    @sub_category = params[:sub_category]

    all_artworks = Artwork.where("LOWER(category) = ? AND LOWER(sub_category) = ? AND published = ?", @category.downcase, @sub_category.downcase, true)

    if @category == 'boutique'
      @highlighted_artworks = all_artworks.where("title ILIKE ?", "Atelier%")
      @artworks = all_artworks.where.not(id: @highlighted_artworks.pluck(:id))

      @artworks = case params[:sort]
                  when 'price_asc'
                    @artworks.order(price: :asc)
                  when 'price_desc'
                    @artworks.order(price: :desc)
                  else
                    @artworks.order(created_at: :desc)
                  end

      render 'artworks/sub_categories/boutique'

    elsif @category == 'prestation'
      @artworks = all_artworks.order(created_at: :desc)
      render 'artworks/sub_categories/prestation'

    elsif @category == 'portfolio'
      @artworks = all_artworks.order(created_at: :desc)
      render 'artworks/sub_categories/portfolio'
    end

    render plain: "Catégorie inconnue", status: :not_found unless performed?
  end

  def new
    @artwork = current_user.artworks.new(category: params[:category])
  end

  def create
    @artwork = current_user.artworks.new(artwork_params)
    if @artwork.save
      redirect_to parmatouze1317_path, notice: "Œuvre ajoutée avec succès."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @artwork.update(artwork_params)
      redirect_to parmatouze1317_path, notice: "Mise à jour réussie."
    else
      render :edit
    end
  end

  def destroy
    @artwork.destroy
    redirect_to parmatouze1317_path, notice: "Œuvre supprimée."
  end

  private

  def set_artwork
    @artwork = Artwork.find(params[:id])
  end

  def verify_owner!
    redirect_to root_path unless @artwork.user == current_user
  end

  def artwork_params
    params.require(:artwork).permit(:title, :description, :price, :category, :sub_category, :shipping_category, :published, images: [])
  end
end
