class WebController < ActionController::Base
  caches_page :terms, :privacy
end