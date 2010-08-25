# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
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

    def get_shopify_products
      @products_ids ||= []
      s_products = ShopifyAPI::Product.find(:all)
      @products = ScheduledProduct.patch_shopify_products(s_products)
    end

end

