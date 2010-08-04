require 'spec_helper'

describe ScheduledProduct do

  before(:all) do
    @store = Factory.create(:store)
  end

  before(:each) do
    @valid_attributes = {

    }
    @from, @to = 2.hours.ago, Time.now
    @products_ids = ['11','22','33']
  end

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
    shopify_products = []
    lambda{ScheduledProduct.unschedule(shopify_products, ['11','22'])}.should change{ScheduledProduct.find(:all).count}.from(3).to(1)
  end

end

