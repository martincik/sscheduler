ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'web'
  map.terms 'terms', :controller => 'web', :action => 'terms'
  map.privacy 'privacy', :controller => 'web', :action => 'privacy'
  
  map.with_options :controller => 'login' do |login|
    login.login 'login'
    login.logout 'login/logout', :action => 'logout'
    login.authenticate 'login/authenticate', :action => 'authenticate'
    login.finalize 'login/finalize', :action => 'finalize'
  end

  map.resources :scheduled_products
  map.resource  :schedule

end

