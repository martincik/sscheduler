# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def is_published(value)
    value.present? && value == true ? 'Published' : 'Unpublished'
  end

  def current_store
    Store.find(session[:store_id])
  end

  def render_flash(flash)
    flash_key = 'error' if flash[:error]
    flash_key = 'notice' if flash[:notice]
    flash_key = 'warning' if flash[:warning]

    if flash_key
      content_tag(:div, flash[flash_key.to_sym], :id => "flash-#{flash_key}",
        :class => 'flash')
    end
  end

end

