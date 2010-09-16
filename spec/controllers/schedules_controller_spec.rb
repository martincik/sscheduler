require 'spec_helper'

describe SchedulesController do

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
    session[:store_id] = @store.id
    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products)
    ShopifyAPI::Product.stub!(:count).and_return(3)
  end

  it "should check scheduling params for schedule" do
    ScheduledProduct.stub!(:schedule)

    # Without params
    post 'create', :commit => 'schedule'
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without time
    post 'create', :products => {'111' => '1'}, :commit => 'schedule'
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without products
    post 'create', :from_time => "1:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :commit => 'schedule'
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # The same from and to
    post 'create', :from_time => "1:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # With from date in past - bad
    post 'create', :from_time => "1:00", :to_time => "1:00",
      :from_date => (Date.today-1.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without to_time param
    post 'create', :from_time => "1:00", :commit => 'schedule',
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Bad time setting from_time > to_time
    post 'create', :from_time => "2:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    response.flash[:notice].should be_blank
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Correct time
    post 'create', :from_time => "1:00", :to_time => "2:00",
      :from_date => (Date.today+1.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    response.flash[:notice].should_not be_blank
    response.flash[:error].should be_blank
    response.should redirect_to(:controller => 'scheduled_products', :action => 'index')
  end

  it "check scheduling params for unschedule " do
    ScheduledProduct.stub!(:unschedule)
    # Without products
    post 'create', :commit => 'unschedule'
    response.flash[:error].should_not be_blank
    response.flash[:notice].should be_blank

    # With products
    post 'create', :products => {'111' => '1'}, :commit => 'unschedule'
    response.flash[:notice].should_not be_blank
    response.flash[:error].should be_blank
  end

end

