class Store < ActiveRecord::Base

  serialize :params, Hash

end

