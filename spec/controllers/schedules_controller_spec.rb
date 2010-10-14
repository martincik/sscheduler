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

  it "should check redirect to scheduling action" do
    controller.should_receive(:schedule).once
    post 'create', :schedule => ''
  end

  it "should check redirect to uscheduling action" do
    controller.should_receive(:unschedule).once
    post 'create'
  end

  it "should render right template for schedule with bad params" do
    post 'create', :schedule => ''
    response.should render_template('scheduled_products/index')
  end

  it "should redirect to correct path for correct schedule" do
    post 'create', :from_time => "1:00", :to_time => "2:00",
      :from_date => (Date.today+1.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'111' => '1'}, :schedule => ''
    response.should redirect_to(scheduled_products_path)
  end

  it "should render right template for unschedule with bad params" do
    post 'create'
    response.should render_template('scheduled_products/index')
  end

  it "should redirect to correct path for correct unschedule" do
    post 'create', :products => {'1' => '1'}
    response.should redirect_to(scheduled_products_path)
  end

  it "should check scheduling params for schedule" do
    ScheduledProduct.stub!(:schedule)

    # Without params
    post 'create', :schedule => ''
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without time
    post 'create', :products => {'111' => '1'}, :schedule => ''
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without products
    post 'create', :from_time => "1:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :schedule => ''
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # The same from and to
    post 'create', :from_time => "1:00", :to_time => "1:00",
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}, :schedule => ''
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # With from date in past - bad
    post 'create', :from_time => "1:00", :to_time => "1:00",
      :from_date => (Date.today-1.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'111' => '1'}, :schedule => ''
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Without to_time param
    post 'create', :from_time => "1:00", :schedule => '',
      :from_date => Date.today.to_s, :to_date => Date.today.to_s,
      :products => {'111' => '1'}
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Bad time setting from_time > to_time
    post 'create', :from_time => "2:00", :to_time => "1:00",
      :from_date => (Date.today+1.days).to_s, :to_date => (Date.today+1.days).to_s,
      :products => {'111' => '1'}, :schedule => ''
    response.flash[:notice].should be_blank
    response.flash[:error].should_not be_blank
    response.should_not be_redirect

    # Correct time
    post 'create', :from_time => "1:00", :to_time => "2:00",
      :from_date => (Date.today+1.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'111' => '1'}, :schedule => ''
    response.flash[:notice].should_not be_blank
    response.flash[:error].should be_blank
    response.should redirect_to(:controller => 'scheduled_products', :action => 'index')
    assigns[:products].should_not be_nil
    assigns[:products].should have(3).items
  end

  it "check scheduling params for unschedule " do
    ScheduledProduct.stub!(:unschedule)
    # Without products
    post 'create'
    response.flash[:error].should_not be_blank
    response.flash[:notice].should be_blank

    # With products
    post 'create', :products => {'111' => '1'}
    response.flash[:notice].should_not be_blank
    response.flash[:error].should be_blank
  end

end

describe SchedulesController, 'Check controller for action from product detail' do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)
    ShopifyAPI::Base.site = 'www.test_site.com'
    @shopify_products = (1..3).inject([]) do |s, i|
      s << ShopifyAPI::Product.new(:id => i)
    end
    @redirect_path = '/scheduled_products/new?id=>2'
    @template = '/scheduled_products/new'
  end

  before(:each) do
    session[:store_id] = @store.id
    session[:shopify] = ShopifyAPI::Session.new(@store.shop, @store.t, @store.params)
    ShopifyAPI::Product.stub!(:find).with(anything()).and_return do |id|
      @shopify_products.find{|s| s.id == id.to_i}
    end
    ShopifyAPI::Product.stub!(:count).and_return(3)
  end

  it "should return right template and product if we change scheduling from product detail - bad params(from>to)" do
    post 'create', :from_time => "1:00", :to_time => "2:00",
      :from_date => (Date.today+2.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'2' => '1'}, :schedule => '', :redirect_to => @redirect_path,
      :template => @template
    response.should render_template(@template)
    assigns[:product].id.should == 2
  end

  it "should return right redirect_path if we change scheduling from product detail - correct params" do
    post 'create', :from_time => "1:00", :to_time => "2:00",
      :from_date => (Date.today+1.day).to_s, :to_date => (Date.today+1.day).to_s,
      :products => {'2' => '1'}, :schedule => '', :redirect_to => @redirect_path,
      :template => @template
    response.should redirect_to(@redirect_path)
  end

  it "should return right redirect_path if we change unscheduling from product detail - correct params" do
    post 'create', :products => {'2' => '1'}, :redirect_to => @redirect_path,
      :template => @template
    response.should redirect_to(@redirect_path)
  end

end

