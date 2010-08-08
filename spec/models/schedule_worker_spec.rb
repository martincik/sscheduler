require 'spec_helper'

describe ScheduleWorker do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)
  end

  before(:each) do
    @valid_attributes = {

    }
    @from, @to = 2.hours.ago, (Time.now+1.hours)
    @products_ids = [1,2,3]
    @shopify_products = []
    @products_ids.each do |id|
      @shopify_products << Factory.build(:shopify_product, :id => id)
    end
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products)
  end

  it "should publish products on shopify" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
    ShopifyAPI::Product.find(:all).each { |product| product.should_receive(:save).once }
    ScheduleWorker.perform
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(false)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should_not include(nil)
  end

  it "should hidden one product on shopify with change from time to future" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduleWorker.perform
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should_not include(nil)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(false)
    ScheduledProduct.schedule([1], (Time.now + 5.minutes), @to, @store)
    ScheduleWorker.perform
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should include(nil)
    ScheduledProduct.find(:all).collect { |product| product.published }.should include(false)
    ShopifyAPI::Product.find(:all).select { |e| e.id == 1 }.first.published_at.should be_false
    ScheduledProduct.find(:all).should have(3).items
  end

  it "should unschedule product(delete him from ScheduletProducts) and hidden him on shopify, because of to time" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduledProduct.schedule([1], @from, (Time.zone.now - 5.minutes), @store)
    lambda{ ScheduleWorker.perform }.should change{ ScheduledProduct.find(:all).count }.by(-1)
    ShopifyAPI::Product.find(:all).select { |e| e.id == 1 }.first.published_at.should be_false
    ShopifyAPI::Product.find(:all).select { |e| e.id == 2 }.first.published_at.should be_true
    ShopifyAPI::Product.find(:all).select { |e| e.id == 3 }.first.published_at.should be_true
  end

  it "should not publish products, because of Time zone (Fiji + 12h)" do
    Time.zone = 'Fiji'
    f, t = (Time.now - 1.hours), (Time.now + 8.hours)
    @from = Time.zone.parse("#{f.hour}:#{f.min}")
    @to = Time.zone.parse("#{t.hour}:#{t.min}") + 2.days
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
    ScheduleWorker.perform
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
  end

  it "should publish products in Time zone Kabul (+4:30)" do
    Time.zone = 'Kabul'
    f, t = (Time.now - 1.hours), (Time.now + 8.hours)
    @from = Time.zone.parse("#{f.year}-#{f.month}-#{f.day} #{f.hour}:#{f.min}")
    @to = Time.zone.parse("#{t.hour}:#{t.min}") + 2.days
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(true)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should == [nil,nil,nil]
    ScheduleWorker.perform
    ScheduledProduct.find(:all).collect { |product| product.published }.should_not include(false)
    ShopifyAPI::Product.find(:all).collect { |product| product.published_at }.should_not include(nil)
  end

end

