class WebController < ActionController::Base
  include ExceptionNotification::Notifiable

  caches_page :terms, :privacy

  def exception
    raise Exception.new('test')
  end
end
