require 'spec_helper'

describe ScheduledProduct do

  before(:all) do
    ScheduledProduct.delete_all
    Store.delete_all
    @store = Factory.create(:store)
    @from, @to = 2.hours.ago, Time.now+1.days
    @products_ids = ['11','22','33']
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
  end

  before(:each) do
    @valid_attributes = {

    }
  end

  it "should return products to publish" do
    ScheduledProduct.to_publish(Time.now).should have(3).items
    ScheduledProduct.update_all("from_time='#{(Time.now+1.hours).to_s(:db)}'", {:shopify_id => 11})
    ScheduledProduct.to_publish(Time.now).should have(2).items
    ScheduledProduct.to_publish(Time.now+2.days).should be_blank
    ScheduledProduct.update_all("to_time='#{(Time.now+3.days).to_s(:db)}'", {:shopify_id => 11})
    ScheduledProduct.to_publish(Time.now+2.days).should have(1).items
  end

  it "should not find product for publish what is published" do
    ScheduledProduct.update_all("published=true", {:shopify_id => 11})
    ScheduledProduct.to_publish(Time.now).should have(2).items
  end

  it "should return products to unpublish" do
    ScheduledProduct.to_unpublish(Time.now).should be_blank
    ScheduledProduct.update_all("to_time='#{(Time.now).to_s(:db)}'", {:shopify_id => 11})
  end

  it "should not return products for unpublish if have from_time > Time.now" do
    ScheduledProduct.update_all("from_time='#{(Time.now+1.hours).to_s(:db)}'", {:shopify_id => 22})
    ScheduledProduct.to_unpublish(Time.now).should be_blank
  end

  it "should set attribute for publish to true" do
    lambda{ ScheduledProduct.publish_all_with_ids([11,22]) }.should change {
      ScheduledProduct.find_all_by_published(true).count
    }.from(0).to(2)
  end

  it "should set attribute for unpublish to false" do
    ScheduledProduct.update_all(:published => true)
    lambda{ ScheduledProduct.unpublish_all_with_ids([11,22]) }.should change {
      ScheduledProduct.all.count
    }.from(3).to(1)
  end

  it "should return ids what are already in DB" do
    ScheduledProduct.existing_ids(@store, [11,33,44]).should have(2).items
    ScheduledProduct.existing_ids(@store, [44,55]).should be_blank
  end

  it "should schedule products" do
    ScheduledProduct.delete_all
    ScheduledProduct.all.should be_blank
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
    products = ScheduledProduct.all
    products.should have(3).items
    products.collect { |product| product.from_time }.uniq.should have(1).items
    products.collect { |product| product.to_time }.uniq.should have(1).items
    products.collect { |product| product.published }.uniq.should have(1).items
  end

  it "should change published attribute if change scheduling" do
    ScheduledProduct.update_all(:published => true)
  end

=begin
  it "should create a new scheduled product" do
    lambda{ScheduledProduct.schedule(@products_ids, @from, @to, @store)}.should change{ScheduledProduct.find(:all).count}.by(3)
  end

  it "should update scheduled product" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduledProduct.find(:all).should have(3).items
    from2 = 1.hours.ago
    lambda{ScheduledProduct.schedule(['11'], from2, @to, @store)}.should change{
      ScheduledProduct.find_by_shopify_id(11).from_time.to_s
    }.from(@from.to_s).to(from2.to_s)
    ScheduledProduct.find_by_shopify_id(22).from_time.to_s.should == @from.to_s
    ScheduledProduct.find_by_shopify_id(33).from_time.to_s.should == @from.to_s
    ScheduledProduct.find(:all).should have(3).items
  end

  it "should unschedule product" do
    ScheduledProduct.schedule(@products_ids, @from, @to, @store)
    ScheduledProduct.find(:all).should have(3).items
    ShopifyAPI::Product.stub!(:put).and_return(:true)
    shopify_products = []
    lambda {
      ScheduledProduct.unschedule(['11','22'])}.should change{ScheduledProduct.find(:all).count
    }.from(3).to(1)
  end
=end
end

