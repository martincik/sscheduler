require 'ruby-debug'
require 'shopify_api'

class ScheduleWorker

  def self.perform
    time_now = Time.now
    Store.find(:all).each do |store|
      shopify_session = ShopifyAPI::Session.new(store.shop, store.t, store.params)
      ShopifyAPI::Base.site = shopify_session.site

      to_publish_ids = ScheduleWorker::get_to_publish(time_now, store.id)
      ScheduleWorker::publish(ShopifyAPI, to_publish_ids)

      to_hide_ids = ScheduleWorker::get_to_hide(time_now, store.id)
      to_delete_ids = ScheduleWorker::get_to_delete(time_now, store.id)
      ScheduleWorker::unpublish(ShopifyAPI, to_delete_ids, to_hide_ids)
    end
  end

  def self.get_to_hide(time_now, store_id)
    ScheduledProduct.find(:all,
        :conditions => ["from_time > :time_now AND store_id=:store_id AND published=true",
        {:time_now => time_now.utc, :store_id => store_id}]).collect { |e| e.shopify_id }
  end

  def self.get_to_publish(time_now, store_id)
    ScheduledProduct.find(:all, :conditions => ["from_time <= :time_now AND to_time > :time_now
        AND store_id=:store_id AND published=false",
        {:time_now => time_now.utc, :store_id => store_id}]).collect { |e| e.shopify_id }
  end

  def self.get_to_delete(time_now, store_id)
    ScheduledProduct.find(:all,
        :conditions => ["to_time <= :time_now AND store_id=:store_id",
        {:time_now => time_now.utc, :store_id => store_id}]).collect { |e| e.shopify_id }
  end

  def self.publish(_ShopifyAPI, to_publish_ids, time_now=Time.now.utc)
    begin
      to_publish_ids.each { |id| ShopifyAPI::Product.put(id, :product => {:published_at => time_now}) }
      ScheduledProduct.update_all("published=true",["shopify_id IN (:ids)", {:ids => to_publish_ids}])
      return true
    rescue Exception => e
      req = _ShopifyAPI::Product.custom_method_collection_url('#{id}', :product => {:published_at => time_now})
      _ShopifyAPI::add_log(req, e)
      return false
    end
  end

  def self.unpublish(_ShopifyAPI, to_delete_ids, to_hide_ids=[])
    begin
      (to_hide_ids + to_delete_ids).each { |id| ShopifyAPI::Product.put(id, :product => {:published_at => nil}) }
      ScheduledProduct.update_all("published=false", ["shopify_id IN (:ids)", {:ids => to_hide_ids}])
      ScheduledProduct.delete_all(["shopify_id IN (:ids)", {:ids => to_delete_ids}])
      return true
    rescue Exception => e
      req = _ShopifyAPI::Product.custom_method_collection_url('#{id}', :product => {:published_at => nil})
      _ShopifyAPI::add_log(req, e)
      return false
    end
  end

end

