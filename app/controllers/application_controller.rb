# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotification::Notifiable

  helper :all # include all helpers, all the time
  include ApplicationHelper
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :set_time_zone

  private

    # Have to set Time zone before each action, before it probably rewrite zone from
    # config.time_zone in environment.rb
    def set_time_zone
      Time.zone = session[:time_zone]
    end

    def get_shopify_products(page, per_page = 5)
      @products_ids ||= []
      @products_count = ShopifyAPI::Product.count
      @per_page = per_page.to_i

      page = page || 1
      @products = WillPaginate::Collection.create(page, per_page, @products_count) do |pager|
        results = ShopifyAPI::Product.find(:all, :params => { :page => page, :limit => pager.per_page })
        pager.replace results
      end
    end

end

