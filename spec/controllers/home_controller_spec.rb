require 'spec_helper'

describe HomeController do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)
    (1..3).each { |i| Factory.build(:shopify_product, :id => i) }
  end

  before(:each) do
    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
    session[:store_id] = @store.id
  end

  it "should get correct callback url " do
    get 'welcome'
    assigns[:callback_url] = "http://localhost:3000/login/finalize"
  end

  it "should check redirect for index" do
    get 'index'
    response.should render_template('index')
    session[:shopify] = nil
    get 'index'
    response.should_not render_template('index')
  end

  it "should check scheduling params for schedule" do
    ScheduledProduct.stub!(:schedule)

    # Without params
    post 'set_schedule', :commit => 'schedule'
    flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without time
    post 'set_schedule', :products => {'111' => '1'}, :commit => 'schedule'
    flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without products
    post 'set_schedule', :from_time => "1:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :commit => 'schedule'
    flash[:error].should_not be_blank
    response.should_not be_redirect

    # The same from and to
    post 'set_schedule', :from_time => "1:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without to_time param
    post 'set_schedule', :from_time => "1:00", :commit => 'schedule',
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}
    flash[:error].should_not be_blank
    response.should_not be_redirect

    # Bad time setting from_time > to_time
    post 'set_schedule', :from_time => "2:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    flash[:notice].should be_blank
    flash[:error].should_not be_blank
    response.should_not be_redirect

    # Correct time
    post 'set_schedule', :from_time => "1:00", :to_time => "2:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}, :commit => 'schedule'
    flash[:notice].should_not be_blank
    flash[:error].should be_blank
    response.should redirect_to(:action => 'index')

  end

  it "check scheduling params for unschedule " do
    ScheduledProduct.stub!(:unschedule)
    # Without products
    post 'set_schedule', :commit => 'unschedule'
    flash[:error].should_not be_blank
    flash[:notice].should be_blank

    # With products
    post 'set_schedule', :products => {'111' => '1'}, :commit => 'unschedule'
    flash[:notice].should_not be_blank
    flash[:error].should be_blank
  end

  it "should change time zone for store" do
    lambda { post 'set_store_time_zone', :store => {:time_zone => 'UTC' } }.should change {
      Store.first.time_zone
    }.from('Prague').to('UTC')
    response.should render_template("index")

  end

end

