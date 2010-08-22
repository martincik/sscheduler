require 'spec_helper'

describe ScheduleWorker do

  before(:all) do
    Store.delete_all
    ScheduledProduct.delete_all
    @store = Factory.create(:store)

    @from, @to = 2.hours.ago, (Time.now+1.hours)
    @products_ids = [1,2,3]
    @shopify_products = []
    @products_ids.each do |id|
      @shopify_products << Factory.build(:shopify_product, :id => id)
    end
    ScheduledProduct.schedule(@store, @products_ids, @from, @to)
    ShopifyAPI::Product.stub!(:custom_method_collection_url)
    ShopifyAPI::Product.stub!(:find).and_return(@shopify_products)
    ShopifyAPI::Product.stub!(:put).with(anything(), an_instance_of(Hash)).and_return do |id, hash|
      if hash[:product][:published_at].nil?
        @shopify_products.find{|s| s.id == id}.published_at = nil
      else
        @shopify_products.find{|s| s.id == id}.published_at = Time.now
      end
    end
  end


  it "should publish shopify products" do
    @shopify_products.map(&:published_at).include?(nil).should be_true
    ScheduledProduct.all.map(&:published).include?(true).should_not be_true
    ScheduleWorker.publish(@store, @products_ids)
    @shopify_products.map(&:published_at).include?(nil).should_not be_true
    ScheduledProduct.all.map(&:published).include?(false).should_not be_true
  end

  it "should unpublish shopify products " do
    ScheduledProduct.update_all :published => true
    ScheduledProduct.all.map(&:published).include?(false).should_not be_true
    #ScheduleWorker.unpublish(@store, @products_ids)

    #@shopify_products.map(&:published_at).include?(nil).should be_true
    #ScheduledProduct.all.map(&:published).include?(true).should_not be_true
  end

  it "should delete product when raise any error" do

  end

  it "should delete product when raise error ActiveResource::ResourceNotFound" do

  end

end

