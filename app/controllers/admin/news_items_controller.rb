module Admin
  class NewsItemsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_news_item, only: [:edit, :update, :destroy]

    def index
      @news_items = NewsItem.order(created_at: :desc)
    end

    def new
      @news_item = NewsItem.new
    end

    def create
      @news_item = NewsItem.new(news_item_params)
      if @news_item.save
        redirect_to admin_dashboard_path, notice: "Actualité créée avec succès ✅"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @news_item.update(news_item_params)
        redirect_to admin_dashboard_path, notice: "Actualité mise à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @news_item.destroy
      redirect_to admin_dashboard_path, notice: "Actualité supprimée avec succès 🗑️"
    end

    private

    def set_news_item
      @news_item = NewsItem.find(params[:id])
    end

    def news_item_params
      params.require(:news_item).permit(
        :title, :date, :location, :description,
        :source, :link, :category,
        photos: []
      )
    end
  end
end
