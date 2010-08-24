require 'active_support'

module Shopify

  mattr_accessor :logger

  class Log < Logger

    def initialize(*args)
      super
      Shopify.logger = self
    end

    def set(file)

    end

    def error(request, error)
      super "E [#{Time.now.to_s(:eu_datetime)}] ERROR: #{error.to_s}, REQ:#{request}"
    end

    def info(request)
      super "I [#{Time.now.to_s(:eu_datetime)}] REQ: #{request}"
    end

  end # class Logger

end

