class HomeController < ApplicationController

  around_filter :shopify_session, :except => 'welcome'

  include HomeHelper

  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"
  end

  def index
    @products_ids = []
    get_products
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  def set_schedule
    params[:products].nil? ? @products_ids = [] : @products_ids = params[:products].keys
    if params[:commit] == "schedule"
      schedule
    else
      unschedule
    end
  end

  private

  def get_products
    s_products = ShopifyAPI::Product.find(:all)
    @products = ScheduledProduct.patch_shopify_products(s_products)
  end

  def schedule
    @from_time, @to_time, @from_date, @to_date = params[:from_time], params[:to_time], params[:from_date], params[:to_date]
    respond_to do |format|
      if check_products and check_times
        ScheduledProduct::schedule(current_store, @products_ids, @from, @to)
        flash[:notice] = "Scheduling was successfully"
        format.html { redirect_to :action => "index" }
        format.xml { render :xml => @products, :notice => flash[:notice]}
      else
        get_products
        format.xml { render :xml => flash }
        format.html { render :action => "index" }
      end
    end

  end

  def unschedule
    respond_to do |format|
      if check_products
        ScheduledProduct::unschedule(current_store, @products_ids)
        flash[:notice] = 'Unscheduling was successfully.'
        format.xml { render :xml => @products, :notice => flash[:notice]}
      else
        format.xml { render :xml => flash }
      end
      format.html { redirect_to home_index_path }
    end
  end


end

