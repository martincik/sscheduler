require 'spec_helper'

describe ScheduleCartsController do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)
    ShopifyAPI::Base.site = 'www.test_site.com'
    @shopify_products = (1..3).inject([]) do |s, i|
      s << ShopifyAPI::Product.new(:id => i)
    end
  end

  before(:each) do
    session[:schedule_cart] = nil
    session[:store_id] = @store.id
    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
  end

  it "provides add product_id to session" do
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products.first)

    post 'create', :product_id => '1' 
   
    session[:schedule_cart].should == [1]
    
    response.should be_success
    response.body.should == " "
  end

  it "do not add product_id to session if doesn't exists on Shopify" do
    ShopifyAPI::Product.stub!(:find).and_return(nil)

    post 'create', :product_id => '1' 
   
    session[:schedule_cart].should == []
    
    response.should be_success
    response.body.should == " "
  end

  it "provides removes product_id from session" do
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products.first)
    session[:schedule_cart] = [1, 2]

    delete 'destroy', :product_id => '1'

    session[:schedule_cart].should == [2]
    
    response.should be_success
    response.body.should == " "
  end

end
