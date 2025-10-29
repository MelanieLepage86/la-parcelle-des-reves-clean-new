module Admin
  class ArtworksController < ApplicationController
    before_action :authenticate_user!

    def toggle_publish
      artwork = Artwork.find(params[:id])
      artwork.toggle!(:published)
      redirect_to admin_dashboard_path, notice: "Statut de publication mis à jour."
    end
  end
end
