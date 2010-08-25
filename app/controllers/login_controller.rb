class LoginController < ApplicationController

  skip_before_filter :set_time_zone

  def index
    # Ask user for their #{shop}.myshopify.com address
    # If the #{shop}.myshopify.com address is already provided in the URL, just skip to #authenticate
    if params[:shop].present?
      redirect_to authenticate_path, :shop => params[:shop]
    end
  end

  def authenticate
    if params[:shop].present?
      redirect_to ShopifyAPI::Session.new(params[:shop].to_s).create_permission_url
    else
      redirect_to return_address
    end
  end

  # Shopify redirects the logged-in user back to this action along with
  # the authorization token t.
  #
  # This token is later combined with the developer's shared secret to form
  # the password used to call API methods.
  def finalize
    shopify_session = ShopifyAPI::Session.new(params[:shop], params[:t], params)
    if shopify_session.valid?
      session[:shopify] = shopify_session
      flash[:notice] = "Logged in to shopify store."
      set_store_and_time_zone
      redirect_to return_address
      session[:return_to] = nil
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to login_path
    end
  end

  def logout
    session[:shopify] = nil
    flash[:notice] = "Successfully logged out."

    redirect_to login_path
  end

  protected

  def return_address
    session[:return_to] || root_url
  end

  def set_store_and_time_zone
    ShopifyAPI::Base.site = session[:shopify].site
    store = Store.find_or_create_by_shop(params[:shop], {:t => params[:t], :params => params})
    session[:store_id] = store.id
    shopify_time_zone = current_shop.shop.timezone.gsub(/^\(GMT[+-]\d{2}:\d{2}\)\ /,'')
    store.update_attributes({:time_zone => shopify_time_zone}) if store.time_zone != shopify_time_zone
    session[:time_zone] = store.time_zone
    Time.zone = store.time_zone
  end
end

