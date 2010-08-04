class ScheduledProduct < ActiveRecord::Base

  validates_presence_of :shopify_id

  def self.schedule(products_ids, from, to, store)
    for_update = ScheduledProduct.find(:all, :conditions => ["shopify_id IN (:ids)", { :ids => products_ids }])
    for_update.collect!{|p| p.shopify_id.to_s}
    for_create = products_ids.collect { |e| e.to_s } - for_update
    for_create.each { |id|  ScheduledProduct.create({:shopify_id => id, :from_time => from.to_formatted_s(:db),
                      :to_time => to.to_formatted_s(:db), :store_id => store.id }) }
    ScheduledProduct.update_all("from_time='#{from.to_formatted_s(:db)}', to_time='#{to.to_formatted_s(:db)}'",
                                  ["shopify_id IN (:ids)", {:ids => for_update}])
    scheduled_products = ScheduledProduct.find(:all).inject({}) do |hash, p|
      hash.merge({p.shopify_id.to_s => p})
    end
  end

  def self.unschedule(shopify_products, products_ids)
    shopify_products.select { |p| products_ids.include?(p.id.to_s) }.each do |product|
      product.published_at = nil
      product.save
    end
    ScheduledProduct.delete_all(["shopify_id IN (:ids)",{:ids => products_ids}])
  end

end

