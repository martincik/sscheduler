require 'shopify_api'

class ScheduleWorker
  class << self

    def perform
      time_now = Time.zone.now
      Store.all.each do |store|
        setup_session(store)
        to_publish_ids = shopify_ids(store.scheduled_products.to_publish(time_now))
        publish(store, to_publish_ids)
        to_unpublish_ids = shopify_ids(store.scheduled_products.to_unpublish(time_now))
        unpublish(store, to_unpublish_ids)
      end
    end

    def publish(store, to_publish_ids)
      change_publish(to_publish_ids, Time.now) do |ids|
        store.scheduled_products.publish_all_with_ids(ids)
      end
    end

    def unpublish(store, to_unpublish_ids)
      change_publish(to_unpublish_ids) do |ids|
        store.scheduled_products.unpublish_all_with_ids(ids)
      end
    end

    private

      def setup_session(store)
        shopify_session = ShopifyAPI::Session.new(store.shop, store.t, store.params)
        ShopifyAPI::Base.site = shopify_session.site
      end

      def change_publish(ids, publish=nil, &block)
        passed_ids = ids
        ids.each do |id|
          begin
            request = ShopifyAPI::Product.custom_method_collection_url('#{id}', :product => {:published_at => publish})
            ShopifyAPI::Product.put(id, :product => {:published_at => publish})
            ShopifyMatters::info_log(request)
          rescue ActiveResource::ResourceNotFound => e
            store.scheduled_products.delete_all(:shopify_id => id)
            ShopifyMatters::error_log(request, e)
            passed_ids.delete(id)
          rescue Exception => e
            ShopifyMatters::error_log(request, e)
            passed_ids.delete(id)
          end
        end

        yield passed_ids

      end

      def shopify_ids(collection)
        collection.map(&:shopify_id)
      end

  end # class << self
end

