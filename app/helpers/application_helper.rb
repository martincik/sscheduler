# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def is_ok_tag(value)
    if value.blank? || value == false
      content_tag(:a, '&nbsp;', {:class => 'isok-false'})
    else
      content_tag(:a, '&nbsp;', {:class => 'isok-true'})
    end
  end

  def current_store
    Store.find(session[:store_id])
  end

end

