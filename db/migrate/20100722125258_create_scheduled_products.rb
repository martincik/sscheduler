class CreateScheduledProducts < ActiveRecord::Migration
  def self.up
    create_table :scheduled_products do |t|
      t.integer :shopify_id
      t.references :store, :null => false
      t.datetime :from_time, :to_time
      t.boolean :published, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_products
  end
end

