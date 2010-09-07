require 'spec_helper'

describe LoginController do

  before(:all) do
    Store.delete_all
  end

  it "should not redirect to authenticate when params[:shop] is nil" do
    get 'index'
    response.should_not be_redirect
  end

  it "should redirect to authenticate when params[:shop] is present" do
    get 'index', :shop => 'test_shop'
    response.should redirect_to(:action => 'authenticate')
  end

  it "should redirect to shop permission page" do
    shop = 'test_shop'
    # api key is loaded from /config/shopify.yml - test
    api_key = ShopifyAPI::Session.api_key
    post 'authenticate', :shop => shop
    response.should redirect_to "http://#{shop}/admin/api/auth?api_key=#{api_key}"
  end

  it "should redirect to login page" do
    post 'authenticate'
    response.should redirect_to home_path
  end

  it "should create store and his time zone after login" do
    Store.all.should be_blank
    shopify_session = mock('session', :valid? => true, :site => 'test_site')
    mock_shop = mock('shop', :timezone => '(GMT-10:00) Hawaii')
    shopify_session.stub!(:shop).and_return(mock_shop)
    ShopifyAPI::Session.stub!(:new).and_return(shopify_session)

    post 'finalize', :shop => 'test_shop'
    Store.all.should have(1).items
    Store.first.time_zone == 'Hawaii'
    session[:time_zone].should == 'Hawaii'
    session[:store_id] == Store.first.id
    response.should redirect_to home_url
  end

  it "should not create store, but set his changed time zone" do
    store = Factory.create(:store)
    shopify_session = mock('session', :valid? => true, :site => 'test_site')
    mock_shop = mock('shop', :timezone => '(GMT-03:00) Brasilia')
    shopify_session.stub!(:shop).and_return(mock_shop)
    ShopifyAPI::Session.stub!(:new).and_return(shopify_session)

    lambda { post 'finalize', :shop => store.shop }.should change {
      Store.first.time_zone
    }.from('Prague').to('Brasilia')
    Store.count.should == 1
    session[:time_zone].should == 'Brasilia'
    session[:store_id] == Store.first.id
    response.should redirect_to home_url
  end

  it "should not finalize authentication - bad params" do
    post 'finalize', :shop => 'bad_shop'
    response.should redirect_to login_path
  end

  it "should clear session after logout" do
    session[:shopify] = 'aaa'
    get 'logout'
    session[:shopify].should be_nil
    response.should redirect_to login_path
  end

end

