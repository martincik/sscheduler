# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def is_published(value)
    value.present? && value == true ? 'Yes' : 'No'
  end

  def current_store
    Store.find(session[:store_id])
  end

  def render_flash(flash)
    if flash[:error]
      flash_key = 'error'
    elsif flash[:notice]
      flash_key = 'notice'
    end
    
    unless flash_key.nil?
      content_tag(:div, flash.now[flash_key.to_sym], :id => "flash#{flash_key}s") 
    end
  end

end

