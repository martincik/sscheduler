# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def is_ok_tag(value)
    value_class = value.present? && value == true
    content_tag(:a, '&nbsp;', :class => "isok-" + value_class)
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
    # ?? Why are u not using flash.now ??
    # ?? Why u care only about :error and :notice and not others ??
    content_tag(:div, flash.now[flash_key.to_sym], :id => "flash#{flash_key}s")
  end

end

