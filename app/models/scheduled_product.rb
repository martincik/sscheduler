class ScheduledProduct < ActiveRecord::Base

  belongs_to :store

  # Validations
  validates_presence_of :shopify_id

  # Scopes
  named_scope :to_publish, lambda { |time|
    { :conditions => ["from_time <= :time AND to_time > :time AND published = false",
      { :time => time }]
    }
  }

  named_scope :to_unpublish, lambda { |time|
    { :conditions => ["to_time <= :time", { :time => time }] }
  }

  class << self

    def publish_all_with_ids(ids)
      update_all("published = true", ["shopify_id IN (:ids)", {:ids => ids}])
    end

    def unpublish_all_with_ids(ids)
      delete_all(["shopify_id IN (:ids)", {:ids => ids}])
    end

    def existing_ids(store, products_ids)
      # return ids like string. Have to use map anyway
      # connection.select_values("SELECT shopify_id FROM scheduled_products WHERE shopify_id IN (#{products_ids.join(',')}) AND store_id=#{store.id}")
      # ScheduledProduct.all(:conditions => ["shopify_id IN (:ids)", {:ids => products_ids}]).map(&:shopify_id)
      
      # It's much faster with only SELECT and stor_id for security resons.
      connection.select_values(<<-eos
        SELECT shopify_id FROM scheduled_products 
        WHERE shopify_id IN (#{products_ids.join(',')}) AND store_id=#{store.id}
      eos).map(&:to_i)
    end

    def schedule(store, products_ids, from, to)
      for_update = existing_ids(store, products_ids)
      for_create = products_ids - for_update
      attributes = for_create.collect do |id|
        { :shopify_id => id, :from_time => from, 
          :to_time => to, :store_id => store.id }
      end
      
      # ?? We don't care about returning values ?? Pica prace!!
      create(attributes)
      update_all({:from_time => from, :to_time => to, :published => false},
        ["shopify_id IN (:ids)", {:ids => for_update}])
    end

    def unschedule(store, products_ids)
      store.scheduled_products.unpublish_all_with_ids(products_ids)
    end

    def patch_shopify_products(products)
      products_ids = products.map(&:id)
      find(:all, :conditions => ['shopify_id IN (:ids)', {:ids => products_ids}]).each do |sp|
        p = products.find { |e| e.id == sp.shopify_id }
        p.from_time = sp.from_time
        p.to_time = sp.to_time
      end
      products
    end

  end # class << self

end

