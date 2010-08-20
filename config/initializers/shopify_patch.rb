#ShopifyAPI::Product.class_eval %q{attr_accessor :from_time, :to_time}
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
    attr_accessor :from_time, :to_time
  end

end

