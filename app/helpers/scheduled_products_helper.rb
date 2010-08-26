module ScheduledProductsHelper
  
  def checkbox_with_selection_for_scheduled_product(product, is_checked, check_product)
    check_box_tag("products[#{product.id}]", "1", is_checked, { 
      :class => check_product.to_s,
      :id => "product_#{product.id}"
    })    
  end
  
end

