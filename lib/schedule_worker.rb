require 'ruby-debug'
require 'shopify_api'

class ScheduleWorker

  def self.perform
    time_now = Time.now
    Store.find(:all).each do |store|
      shopify_session = ShopifyAPI::Session.new(store.shop, store.t, store.params)
      ShopifyAPI::Base.site = shopify_session.site

      to_publish_ids = ScheduledProduct.find(:all, :conditions => ["from_time <= :time_now AND to_time > :time_now
        AND store_id=:store_id AND published=false",
        {:time_now => time_now, :store_id => store.id}]).collect { |e| e.shopify_id }
      shopify_products = ShopifyAPI::Product.find(:all)
      shopify_products.select { |p| to_publish_ids.include?(p.id) }.each do |p|
        p.published_at = Time.now
        p.save
        puts "#{p.title} was published."
      end
      ScheduledProduct.update_all("published=true",["shopify_id IN (:ids)", {:ids => to_publish_ids}])

      to_hide_ids = ScheduledProduct.find(:all,
        :conditions => ["from_time > :time_now AND published=true", {:time_now => time_now}]).collect { |e| e.shopify_id }

      to_delete_ids = ScheduledProduct.find(:all,
        :conditions => ["to_time <= :time_now", {:time_now => time_now}]).collect { |e| e.shopify_id }
      shopify_products.select { |p| (to_hide_ids + to_delete_ids).include?(p.id) }.each do |p|
        p.published_at = nil
        p.save
        puts "#{p.title} was hidden."
      end
      ScheduledProduct.update_all("published=false", ["shopify_id IN (:ids)", {:ids => to_hide_ids}])
      ScheduledProduct.delete_all(["shopify_id IN (:ids)", {:ids => to_delete_ids}])
    end
  end

end

