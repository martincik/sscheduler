require 'spec_helper'

describe ScheduledProductsController do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)
    ShopifyAPI::Base.site = 'www.test_site.com'
    @shopify_products = (1..3).inject([]) do |s, i|
      Factory(:scheduled_product, :shopify_id => i)
      s << ShopifyAPI::Product.new(:id => i)
    end
  end

  before(:each) do
    session[:store_id] = @store.id
    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products)
    ShopifyAPI::Product.stub!(:count).and_return(3)
  end

  it "should check redirect for index we are sign-on to shopify" do
    get 'index'
    response.should render_template('index')
    session[:shopify] = nil
    get 'index'
    response.should_not render_template('index')
  end

  it "should get shopify products and patch them with times" do
    get 'index'
    assigns[:products].should have(3).items
    assigns[:products].map(&:from_time).should_not include(nil)
  end

  it "should return specified shopify product in action new" do
    ShopifyAPI::Product.stub!(:find).with(anything()).and_return do |id|
      @shopify_products.find{|s| s.id == id.to_i}
    end

    get 'new', :id => @shopify_products.first.id
    assigns[:product].should_not be_nil
    assigns[:product].id.should == @shopify_products.first.id
  end

end

