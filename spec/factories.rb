login_params = {:shop => "zdenal.myshopify.com",
  :timestamp => "1280677209",
  :signature => "0ea4939f892642493f472ddeb477089d",
  :action => "finalize",
  :controller => "login",
  :t => "dcbb2917e7ee3920e874a417d56531ae"
}

Factory.define :store do |s|
  s.shop 'zdenal.myshopify.com'
  s.t 'dcbb2917e7ee3920e874a417d56531ae'
  s.params login_params
end

Factory.define :scheduled_product do |s|
  s.shopify_id '111'
  s.store_id {|s| s.association(:store)}
  s.from_time 2.hours.ago.to_s(:db)
  s.to_time((Time.now+2.hours).to_s(:db))
  s.published false
end

