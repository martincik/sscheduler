class ShopifyMatters
  @@logger = nil

  class << self

    def logger=(log)
      @@logger = log
    end

    def logger
      @@logger
    end

    def error_log(request, error)
      logger.error "E [#{Time.now.to_s(:eu_datetime)}] ERROR: #{error.to_s}, REQ:#{request}"
    end

    def info_log(request)
      logger.info "I [#{Time.now.to_s(:eu_datetime)}] REQ: #{request}"
    end

  end # class << self

end

