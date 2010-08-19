require 'spec_helper'

describe ScheduleWorker do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)
  end

  before(:each) do
    @from, @to = 2.hours.ago, (Time.now+1.hours)
    @products_ids = [1,2,3]
    @shopify_products = []
    @products_ids.each do |id|
      @shopify_products << Factory.build(:shopify_product, :id => id)
    end
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products)
    ShopifyAPI::Product.stub!(:put).with(anything(), an_instance_of(Hash)).and_return do |id, hash|
      if hash[:product][:published_at].nil?
        @shopify_products.find{|s| s.id == id}.published_at = nil
      else
        @shopify_products.find{|s| s.id == id}.published_at = Time.now
      end
    end
  end

  it "should not find products to publish (with testing time zones)" do
    Time.zone = 'Kabul'
    @from = Time.zone.now + 2.seconds
    @to = Time.zone.now + 2.days
    time_now = Time.now
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduleWorker::get_to_publish(time_now, @store.id).should be_blank
  end
=begin
  it "should find products to publish (with testing time zones)" do
    Time.zone = 'Fiji'
    @from = Time.zone.now - 2.seconds
    @to = Time.zone.now + 2.days
    time_now = Time.now
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduleWorker::get_to_publish(time_now, @store.id).should_not be_blank
  end

  it "should publish products on shopify" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
    ScheduleWorker.perform
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(false)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should_not include(nil)
  end

  it "should hidden one product on shopify with change from time to future" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduleWorker.perform
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should_not include(nil)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(false)
    ScheduledProduct.schedule(['1'], (Time.now + 5.minutes), @to, @store.id)
    ScheduleWorker.perform
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should include(nil)
    ScheduledProduct.find(:all).collect { |product| product.published }.should include(false)
    ShopifyAPI::Product.find(:all).select { |e| e.id == 1 }.first.published_at.should be_false
    ScheduledProduct.find(:all).should have(3).items
  end

  it "should unschedule product(delete him from ScheduletProducts) and hidden him on shopify, because of to time" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduledProduct.schedule(['1'], @from, (Time.zone.now - 5.minutes), @store.id)
    lambda{ ScheduleWorker.perform }.should change{ ScheduledProduct.find(:all).count }.by(-1)
    ShopifyAPI::Product.find(:all).select { |e| e.id == 1 }.first.published_at.should be_false
    ShopifyAPI::Product.find(:all).select { |e| e.id == 2 }.first.published_at.should be_true
    ShopifyAPI::Product.find(:all).select { |e| e.id == 3 }.first.published_at.should be_true
  end

  it "should not publish products, because of Time zone (Fiji + 12h)" do
    Time.zone = 'Fiji'
    @from = Time.zone.now - 1.hours
    @to = Time.zone.now + 1.hours
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
    ScheduleWorker.perform
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
  end

  it "should publish products in Time zone Kabul (+4:30)" do
    Time.zone = 'Kabul'
    @from = Time.zone.now + 1.hours
    @to = Time.zone.now + 2.days
    ScheduledProduct.schedule(@products_ids, @from, @to, @store.id)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
    ScheduleWorker.perform
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(false)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should_not include(nil)
  end
=end
end

