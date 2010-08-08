class AddTimeZone < ActiveRecord::Migration
  def self.up
    add_column :stores, :time_zone, :string
  end

  def self.down
    remove_column :stores, :time_zone
  end
end

