login_params = {:shop => "zdenal.myshopify.com",
  :timestamp => "1280677209",
  :signature => "0ea4939f892642493f472ddeb477089d",
  :action => "finalize",
  :controller => "login",
  :t => "dcbb2917e7ee3920e874a417d56531ae"
}

class ShopifyProduct
  attr_accessor :id, :published_at, :title, :from_time, :to_time

  def initialize; end;

  def save
    return true
  end

end


Factory.define :store do |s|
  s.shop 'zdenal.myshopify.com'
  s.t 'dcbb2917e7ee3920e874a417d56531ae'
  s.params login_params
  s.time_zone 'Prague'
end

Factory.define :scheduled_product do |s|
  s.shopify_id 111
  s.store_id {|s| s.association(:store)}
  s.from_time(Time.now - 2.hours).to_s(:db)
  s.to_time((Time.now+8.hours).to_s(:db))
  s.published false
end

Factory.define :shopify_product do |p|
  p.published_at nil
  p.from_time nil
  p.to_time nil
end

