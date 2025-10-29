class NewsItemsController < ApplicationController
  def index
    @grouped_news = NewsItem.grouped_for_display
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end
end
