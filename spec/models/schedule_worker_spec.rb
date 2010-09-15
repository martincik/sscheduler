require 'spec_helper'

describe ScheduleWorker do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)

    @from, @to = 2.hours.ago, (Time.now+1.hours)
    @products_ids = [1,2,3]
    @shopify_products = []
    ShopifyAPI::Base.site = 'www.test_site.com'
    @shopify_products = (1..3).inject([]) do |s, i|
      s << ShopifyAPI::Product.new(:id => i)
    end
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
  end

  # had to put 'stub!' to :each block, because in first test its worked, but in
  # next tests not if this was in :all block (for rake spec command)
  before(:each) do
    ShopifyAPI::Product.stub!(:custom_method_collection_url)
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products)
    ShopifyAPI::Product.stub!(:put).with(anything(), an_instance_of(Hash)).and_return do |id, hash|
      if hash[:product][:published_at].nil?
        @shopify_products.find{|s| s.id == id}.published_at = nil
      else
        @shopify_products.find{|s| s.id == id}.published_at = Time.now
      end
    end
    @shopify_products.collect { |sp| sp.published_at = nil }
  end

  it "should publish shopify products and log it" do
    Shopify.logger.should_receive(:info).exactly(3).times
    @shopify_products.map(&:published_at).include?(nil).should be_true
    ScheduledProduct.all.map(&:published).include?(true).should_not be_true
    ScheduleWorker.publish(@store, @products_ids)
    @shopify_products.map(&:published_at).include?(nil).should_not be_true
    ScheduledProduct.all.map(&:published).include?(false).should_not be_true
  end

  it "should unpublish shopify products " do
    ScheduledProduct.update_all :published => true
    ScheduledProduct.all.map(&:published).include?(false).should_not be_true
    ScheduleWorker.unpublish(@store, @products_ids)
    @shopify_products.map(&:published_at).include?(nil).should be_true
    ScheduledProduct.all.map(&:published).include?(true).should_not be_true
  end

  it "should set session and ShopifyAPI" do
    ScheduleWorker.send(:setup_session, @store).should be_true
  end

  it "should not set session and ShopifyAPI" do
    @store.params[:shop] = 'badstore.myshopify.com'
    ScheduleWorker.send(:setup_session, @store).should be_false
    # Had to chenge it back, because it change it in other tests (like home_controller_spec.rb)
    @store.params[:shop] = "zdenal.myshopify.com"
  end

  it "should get collection of shopify_ids" do
    ScheduleWorker.send(:shopify_ids, @store.scheduled_products).should == [1,2,3]
  end

  it "should publish all products after run perform action" do
    ScheduledProduct.all.map(&:published).should_not include(true)
    @shopify_products.map(&:published_at).uniq.should have(1).items
    ScheduleWorker.perform
    ScheduledProduct.all.map(&:published).should_not include(false)
    @shopify_products.map(&:published_at).should_not include(nil)
  end

  it "should publish only 2 products and then one of them unpublish" do
    ScheduledProduct.find_by_shopify_id(3).update_attributes(:from_time => Time.now+1.minutes)
    ScheduledProduct.find_by_published(true).should be_nil
    @shopify_products.map(&:published_at).should == [nil,nil,nil]
    ScheduleWorker.perform
    ScheduledProduct.find_all_by_published(true).should have(2).items
    @shopify_products.detect { |sp| sp.id == 3 }.published_at.should be_nil
    @shopify_products.detect { |sp| sp.id == 2 }.published_at.should_not be_nil
    @shopify_products.detect { |sp| sp.id == 1 }.published_at.should_not be_nil
    # should unpublish product
    ScheduledProduct.find_by_shopify_id(2).update_attributes(:to_time => Time.now-2.seconds)
    ScheduleWorker.perform
    ScheduledProduct.find_all_by_published(true).should have(1).items
    @shopify_products.detect { |sp| sp.id == 3 }.published_at.should be_nil
    @shopify_products.detect { |sp| sp.id == 2 }.published_at.should be_nil
    @shopify_products.detect { |sp| sp.id == 1 }.published_at.should_not be_nil
  end

  it "should delete product when raise error ActiveResource::ResourceNotFound" do
    ScheduledProduct.all.map(&:shopify_id).should == [1,2,3]
    ShopifyAPI::Product.should_receive(:put).once.with(3, an_instance_of(Hash)).and_raise(
      ActiveResource::ResourceNotFound.new(mock('err', :code => '404'))
    )
    Shopify.logger.should_receive(:error).once
    ScheduleWorker.publish(@store, @products_ids)
    ScheduledProduct.all.map(&:shopify_id).should == [1,2]
  end

  it "should raise Error with ActiveResource::ResourceConflict" do
    ShopifyAPI::Product.should_receive(:put).once.with(2, an_instance_of(Hash)).and_raise(
      ActiveResource::ResourceConflict.new(mock('err', :code => '409'))
    )
    Shopify.logger.should_receive(:error).once
    lambda { ScheduleWorker.unpublish(@store, @products_ids) }.should raise_error(
      ActiveResource::ResourceConflict
    )
  end

end

