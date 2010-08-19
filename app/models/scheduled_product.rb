class ScheduledProduct < ActiveRecord::Base

  # Validations
  validates_presence_of :shopify_id
  
  # Scopes
  named_scope :to_publish, lambda { |time, store|
    { :conditions => ["from_time <= :time AND to_time > :time AND store_id = :store_id AND published = false",
      { :time => time, :store_id => store.id }]
    }
  }
  
  named_scope :to_unpublish, lambda { |time, store|
    { :conditions => ["from_time > :time AND store_id = :store_id AND published = true",
      { :time => time, :store_id => store.id }]
    }
  }
  
  named_scope :to_delete, lambda { |time, store|
    { :conditions => ["to_time <= :time AND store_id = :store_id",
      { :time => time, :store_id => store.id }]
    }
  }
  
  class << self

    def publish_all_with_ids(ids)
      update_all("published = true", ["shopify_id IN (:ids)", {:ids => ids}])
    end
  
    def unpublish_all_with_ids(ids)
      update_all("published = false", ["shopify_id IN (:ids)", {:ids => ids}])
    end
  
    def delete_all_with_ids(ids)
      delete_all(["shopify_id IN (:ids)", {:ids => ids}])
    end
  
    def schedule(products_ids, from, to, store_id)
      for_update = ScheduledProduct.connection.select_values("SELECT shopify_id FROM scheduled_products WHERE shopify_id IN (#{products_ids.join(',')})")
      for_create = products_ids - for_update
      for_create.each { |id|  ScheduledProduct.create({:shopify_id => id, :from_time => from,
                        :to_time => to, :store_id => store_id }) }
      ScheduledProduct.update_all({:from_time => from, :to_time => to},
                                    ["shopify_id IN (:ids)", {:ids => for_update}])
    end

    def unschedule(products_ids)
      ScheduleWorker::unpublish(ShopifyAPI, products_ids)
    end

    def patch_shopify_products(products)
      products_ids = products.map(&:id)
      ScheduledProduct.find(:all, :conditions => ['shopify_id IN (:ids)', {:ids => products_ids}]).each do |sp|
        p = products.find { |e| e.id == sp.shopify_id }
        p.from_time = sp.from_time
        p.to_time = sp.to_time
      end
      products
    end
    
  end # class << self
  
end

