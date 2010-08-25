class ScheduledProductsController < ApplicationController

  around_filter :shopify_session

  def index
    get_shopify_products
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

end

