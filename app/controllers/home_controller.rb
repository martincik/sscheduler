class HomeController < ApplicationController

  around_filter :shopify_session, :except => 'welcome'

  include HomeHelper

  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"
  end

  def index
    @products_ids = []
    @products = ShopifyAPI::Product.find(:all)
    @scheduled_products = ScheduledProduct.find(:all).inject({}) do |hash, p|
      hash.merge({p.shopify_id.to_s => p})
    end
  end

  def set_schedule
    index
    @from_time, @to_time, @from_date, @to_date = params[:from_time], params[:to_time], params[:from_date], params[:to_date]
    @products_ids = params[:products].keys unless params[:products].nil?
    # Check if schedule parameters are valid - check_schedule is in home_helper
    render :action => "index" and return unless check_schedule

    if params[:commit] == "schedule"
      @scheduled_products = ScheduledProduct::schedule(@products_ids, @from, @to, session[:store])
    else
      ScheduledProduct::unschedule(@products, @products_ids)
    end
    flash[:notice] = 'Scheduling was successfully.'
    redirect_to :action => "index"
  end

  def test
    ShopifyAPI::Product.find(:all).each do |product|
      product.published_at = nil
      product.save
    end
  end

end

