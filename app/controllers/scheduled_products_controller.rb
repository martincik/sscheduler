class ScheduledProductsController < ApplicationController

  around_filter :shopify_session

  def index
    get_shopify_products
  end

end

