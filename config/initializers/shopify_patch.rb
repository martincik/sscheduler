#ShopifyAPI::Product.class_eval %q{attr_accessor :from_time, :to_time}
module ShopifyAPI

  @@logger = nil

  def ShopifyAPI.logger=(log)
    @@logger = log
  end

  def ShopifyAPI.logger
    @@logger
  end

  def ShopifyAPI.add_log(msg, error)
    @@logger.error "[#{Time.now.to_s(:eu_datetime)}] ERROR: #{error.to_s}, REQ:#{msg}"
  end

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

ShopifyAPI::logger = Logger.new(Rails.root.join("log",Rails.env + "_shopify.log"))
ShopifyAPI::logger.datetime_format = "%Y-%m-%d %H:%M:%S"

