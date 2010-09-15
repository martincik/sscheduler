module ScheduledProductsHelper

  def checkbox_with_selection_for_scheduled_product(product, is_checked, check_product)
    check_box_tag("products[#{product.id}]", "1", is_checked, {
      :class => check_product.to_s,
      :id => "product_#{product.id}"
    })
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
    tags_string.split(',').map { |tag|
      "<span>#{tag.strip}</span>"
    }
  end

end

