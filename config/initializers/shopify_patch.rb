module ShopifyAPI

  class Session
    def initialize(url, token = nil, params = nil)
      self.url, self.token = url, token

      if params && params[:signature]
        unless self.class.validate_signature(params)
          raise "Invalid Signature: Possible malicious login"
        end
      end

      self.class.prepare_url(self.url)
    end
  end

  class Product
    def from_time
      scheduled_product and scheduled_product.from_time
    end

    def to_time
      scheduled_product and scheduled_product.to_time
    end
    
    private
    
      def scheduled_product
        @scheduled_product ||= ScheduledProduct.find_by_shopify_id(id)
      end
  end

end

