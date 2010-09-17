class ScheduleCartsController < ApplicationController

  before_filter :init_schedule_cart
  around_filter :shopify_session

  def create
    with_schedule_cart do |product|
      session[:schedule_cart] << product.id
    end
  end

  def destroy 
    with_schedule_cart do |product|
      session[:schedule_cart].delete(product.id)
    end
  end
 
  private

  def init_schedule_cart
    session[:schedule_cart] ||= []
  end
  
  def with_schedule_cart(&block)
    product = ShopifyAPI::Product.find(params[:product_id].to_i)
    if product
      yield(product)
    end
    respond_to do |format|
      format.js { head :ok }
    end
  end

end
