class ScheduledProduct < ActiveRecord::Base

  validates_presence_of :shopify_id

  def self.schedule(products_ids, from, to, store_id)
    for_update = ScheduledProduct.connection.select_values("SELECT shopify_id FROM scheduled_products WHERE shopify_id IN (#{products_ids.join(',')})")
    for_create = products_ids - for_update
    for_create.each { |id|  ScheduledProduct.create({:shopify_id => id, :from_time => from,
                      :to_time => to, :store_id => store_id }) }
    ScheduledProduct.update_all({:from_time => from, :to_time => to},
                                  ["shopify_id IN (:ids)", {:ids => for_update}])
  end

  def self.unschedule(products_ids)
    ScheduleWorker::unpublish(ShopifyAPI, products_ids)
  end

  def self.patch_shopify_products(products)
    products_ids = products.collect { |p| p.id }
    ScheduledProduct.find(:all, :conditions => ['shopify_id IN (:ids)', {:ids => products_ids}]).each do |sp|
      p = products.find { |e| e.id == sp.shopify_id }
      p.from_time = sp.from_time
      p.to_time = sp.to_time
    end
    products * 100
  end

end

