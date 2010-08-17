require 'spec_helper'


describe HomeController do

  before(:all) do
    @store = Factory.build(:store)
  end

  it "should check redirect for index" do
    get 'index'
    response.should_not render_template('index')

    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
    get 'index'
    response.should render_template('index')
  end

  it "should check scheduling params" do
    ScheduledProduct.stub!(:schedule)
    ScheduledProduct.stub!(:unschedule).and_return(true)
    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
    post 'set_schedule'
    flash[:error].should_not be_blank
    #response.should be_redirect#(home_index_path)
    flash[:error] = ''

    post 'set_schedule', :from_time => "1:00", :to_time => "1:00", :commit => 'schedule',
      :from_date => Time.now.to_s(:eu_date), :to_date => Time.now.to_s(:eu_date)
    flash[:error].should_not be_blank
    flash[:error] = ''

    post 'set_schedule', :from_time => "1:00", :commit => 'schedule',
      :from_date => Time.now.to_s(:eu_date), :to_date => Time.now.to_s(:eu_date)
    flash[:error].should_not be_blank
    flash[:error] = ''

    post 'set_schedule', :from_time => "1:00", :to_time => "2:00",
      :from_date => Time.now.to_s(:eu_date), :to_date => Time.now.to_s(:eu_date),
      :products => {'111' => '1'}, :commit => 'schedule'
    flash[:notice].should_not be_blank
    flash[:error].should be_blank

  end

end

