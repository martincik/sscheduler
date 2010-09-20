module ScheduledProductsHelper

  def checkbox_with_selection_for_scheduled_product(product)
    check_box_tag("products[#{product.id}]", "1",
      session[:schedule_cart].include?(product.id),
      :id => "checkbox_product_#{product.id}",
      :class => "checkbox_product")
  end

  def classes_for_product_row(product, last_product)
    klass =  []
    klass << 'selected' if session[:schedule_cart].include?(product.id)
    klass << 'last' if last_product == product
    klass.empty? ? '' : " class='#{klass.join(' ')}'"
  end

  def product_photo_thumb(product)
    return if product.images.blank?
    image_tag transform_to_thumbs(product.images.first.src)
  end

  def transform_to_thumbs(src)
    return if src.nil?
    src.gsub(/\.\w{3}\?/) {|s| "_thumb#{s}"}
  end

  def format_tags(tags_string)
    return if tags_string.blank?
    tags_string.split(',').map do |tag|
      "<span>#{tag.strip}</span>"
    end
  end

  def scheduling_button(name, options={}, schedule=true)
    options.merge!({:name => 'schedule'}) if schedule
    content_tag(:button, name, options.merge({:type => 'submit'}))
  end

end

