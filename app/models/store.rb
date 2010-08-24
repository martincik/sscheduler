class Store < ActiveRecord::Base

  serialize :params, Hash

  has_many :scheduled_products, :dependent => :destroy

end

