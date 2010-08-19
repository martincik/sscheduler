require 'shopify_api'

class ScheduleWorker
  class << self
    
    def perform
      time_now = Time.now
      Store.all.each do |store|
        setup_session(store)
      
        to_publish_ids = shopify_ids(ScheduledProduct.to_publish(time_now.utc, store))
        publish(ShopifyAPI, to_publish_ids)

        to_hide_ids = shopify_ids(ScheduledProduct.to_hide(time_now.utc, store))
        to_delete_ids = shopify_ids(ScheduledProduct.to_delete(time_now.utc, store))

        unpublish(ShopifyAPI, to_delete_ids, to_hide_ids)
      end
    end

    def publish(_ShopifyAPI, to_publish_ids, time_now=Time.now.utc)
      begin
        to_publish_ids.each do |id| 
          ShopifyAPI::Product.put(id, :product => {:published_at => time_now})
        end
        
        ScheduledProduct.publish_all_with_ids(to_publish_ids)
      rescue Exception => e
        req = _ShopifyAPI::Product.custom_method_collection_url('#{id}', :product => {:published_at => time_now})
        _ShopifyAPI::add_log(req, e)
      end
    end

    def unpublish(_ShopifyAPI, to_delete_ids, to_hide_ids=[])
      begin
        (to_hide_ids + to_delete_ids).each do |id| 
          ShopifyAPI::Product.put(id, :product => {:published_at => nil})
        end

        ScheduledProduct.unpublish_all_with_ids(to_hide_ids)
        ScheduledProduct.delete_all_with_ids(to_delete_ids)
      rescue Exception => e
        req = _ShopifyAPI::Product.custom_method_collection_url('#{id}', :product => {:published_at => nil})
        _ShopifyAPI::add_log(req, e)
      end
    end
  
    private
  
      def setup_session(store)
        shopify_session = ShopifyAPI::Session.new(store.shop, store.t, store.params)
        ShopifyAPI::Base.site = shopify_session.site      
      end
  
      def shopify_ids(collection)
        collection.map(&:shopify_id)
      end

  end # class << self
end

