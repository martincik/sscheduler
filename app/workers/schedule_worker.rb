require 'shopify_api'

class ScheduleWorker
  class << self

    def perform
      time_now = Time.zone.now
      Store.all.each do |store|
        next unless setup_session(store)
        to_publish_ids = shopify_ids(store.scheduled_products.to_publish(time_now))
        publish(store, to_publish_ids)
        to_unpublish_ids = shopify_ids(store.scheduled_products.to_unpublish(time_now))
        unpublish(store, to_unpublish_ids)
      end
    end

    def publish(store, to_publish_ids)
      change_publish(to_publish_ids, store, Time.zone.now) do |ids|
        store.scheduled_products.publish_all_with_ids(ids)
      end
    end

    def unpublish(store, to_unpublish_ids)
      change_publish(to_unpublish_ids, store) do |ids|
        store.scheduled_products.unpublish_all_with_ids(ids)
      end
    end

    private

      def setup_session(store)
        begin
          shopify_session = ShopifyAPI::Session.new(store.shop, store.t, store.params)
          ShopifyAPI::Base.site = shopify_session.site
          return true
        rescue RuntimeError => e
          msg = "Bad store's params. Store id: #{store.id}, shop: #{store.shop}."
          ShopifyMatters::error_log(msg, e)
          return false
        end
      end

      def change_publish(ids, store, publish=nil, &block)
        passed_ids = []
        ids.each do |id|
          begin
            request = ShopifyAPI::Product.custom_method_collection_url("#{id}", :product => {:published_at => publish})
            ShopifyAPI::Product.put(id, :product => {:published_at => publish})
            ShopifyMatters::info_log(request)
            passed_ids << id
          rescue ActiveResource::ResourceNotFound => e
            store.scheduled_products.find_by_shopify_id(id).delete
            ShopifyMatters::error_log(request, e)
          #rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
          rescue Exception => e
            ShopifyMatters::error_log(request, e)
            raise e
          end
        end

        yield passed_ids

      end

      def shopify_ids(collection)
        collection.map(&:shopify_id)
      end

  end # class << self
end

