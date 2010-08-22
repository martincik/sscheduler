require 'spec_helper'

describe ScheduledProduct, "Test model methods" do

  before(:all) do
    ScheduledProduct.delete_all
    Store.delete_all
    @store = Factory.create(:store)
    @from, @to = 2.hours.ago, Time.now+1.days
    @products_ids = [11,22,33]
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
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

  it "should not find product for publish what have to_time < time now" do
    ScheduledProduct.update_all(:to_time => (Time.now-10.seconds))
    ScheduledProduct.to_publish(Time.now).should be_blank
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
      ScheduledProduct.count
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

  it "should update scheduled product" do
    ScheduledProduct.count.should == 3
    from2 = 1.hours.ago
    lambda{ScheduledProduct.schedule(@store, [11], from2, @to)}.should change{
      ScheduledProduct.find_by_shopify_id(11).from_time.to_s
    }.from(@from.to_s).to(from2.to_s)
    ScheduledProduct.find_by_shopify_id(22).from_time.to_s.should == @from.to_s
    ScheduledProduct.find_by_shopify_id(33).from_time.to_s.should == @from.to_s
    ScheduledProduct.count.should == 3
  end

  it "should change published attribute if change scheduling" do
    ScheduledProduct.update_all(:published => true)
    lambda { ScheduledProduct.schedule(@store, [11], @from, @to) }.should change {
      ScheduledProduct.find_all_by_published(false).count
    }.from(0).to(1)
    ScheduledProduct.count.should == 3
  end

  it "should unschedule selected products for specified store" do
    lambda { ScheduledProduct.unschedule(@store, [22]) }.should change {
      ScheduledProduct.count
    }.from(3).to(2)
    @other_store = Factory.build(:store, :id => @store.id+1)
    lambda { ScheduledProduct.unschedule(@other_store, [11]) }.should_not change {
      ScheduledProduct.count
    }
  end

  it "should patch shopify products for from and to time" do
    @shopify_products = @products_ids.collect { |id| Factory.build(:shopify_product, :id => id) }
    lambda { ScheduledProduct.patch_shopify_products(@shopify_products) }.should change {
      @shopify_products.map(&:from_time).include? nil
    }.from(true).to(false)
  end

end

describe ScheduledProduct, "Test time zones" do

  before(:all) do
    ScheduledProduct.delete_all
    Store.delete_all
    @store = Factory.create(:store)
    @products_ids = [11,22,33]
  end

  it "should not find products to publish 1. case" do
    # I am in Kabul and schedule products with from_time > time now
    Time.zone = 'Kabul'
    @from = Time.zone.now + 15.seconds
    @to = Time.zone.now + 2.days
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
    # And in same moment in Prag I am looking for product what has to be published
    Time.zone = 'Prague'
    time_now = Time.zone.now
    # Has to don't find products to publish
    ScheduledProduct.to_publish(time_now).should be_blank
  end

  it "should find products to publish 2. case" do
    # I am in Kabul and schedule products with from_time < time now
    Time.zone = 'Kabul'
    @from = Time.zone.now - 15.seconds
    @to = Time.zone.now + 2.days
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
    # And in same moment in Prag I am looking for product what has to be published
    Time.zone = 'Prague'
    time_now = Time.zone.now
    # Has to don't find products to publish
    ScheduledProduct.to_publish(time_now).should_not be_blank
  end

  it "should find products to publish 3. case" do
    # I am in Athens and schedule products with from_time > time now,
    # so they should not be find to publish when I use Time.zone.now in Prag for looking
    Time.zone = 'Athens'
    @from = Time.zone.now + 15.seconds
    @to = Time.zone.now + 2.days
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
    # And when I am in Prag in time what is in Athens I should find products to publish,
    # because in this time is in Athens 1 hour more
    Time.zone = 'Prague'
    time_now = (Time.zone.parse @from.to_s)+15.seconds
    ScheduledProduct.to_publish(time_now).should_not be_blank
  end

  it "should not find products to publish 4. case" do
    # I am in London and schedule products with from_time < time now,
    # so they should be find to publish when I use Time.zone.now in Prag for looking
    Time.zone = 'London'
    @from = Time.zone.now - 15.seconds
    @to = Time.zone.now + 2.days
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
    # And when I am in Prag in time what is in London I should find products to publish,
    # because in this time is in London 1 hour less
    Time.zone = 'Prague'
    time_now = (Time.zone.parse @from.to_s)
    ScheduledProduct.to_publish(time_now).should be_blank
  end

end

