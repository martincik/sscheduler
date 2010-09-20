class ScheduledProductsController < ApplicationController

  around_filter :shopify_session

  def index
    session[:schedule_cart] ||= []
    get_shopify_products(params[:page], params[:per_page] || 5)
  end

  def new
    @product = ShopifyAPI::Product.find(params[:id])
  end

end

