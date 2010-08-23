module TabsHelper
  # Create a tab as <li> and give it the id "current" if the current action matches that tab
  def tab(name, url, options = {})
    html_options = {}
    
    if controller.action_name =~ (options[:highlight] = /#{name}/i)
      html_options = {:id => "current"}
    end
    
    content_tag :li, link_to(options[:label] || name.to_s.capitalize, url, html_options)    
  end
end