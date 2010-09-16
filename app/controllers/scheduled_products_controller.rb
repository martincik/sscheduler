class ScheduledProductsController < ApplicationController

  around_filter :shopify_session

  def index
    get_shopify_products(params[:page], params[:per_page] || 5)
  end

end

