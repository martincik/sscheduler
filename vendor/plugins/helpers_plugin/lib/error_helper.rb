module ActionView
  module Helpers
    module ActiveRecordHelper
      def error_messages_for(object_name, options = {})
        options = options.symbolize_keys
        errors = []
        object = nil
        if object_name.is_a?(Array)
          object_name.each do |o|
            object = instance_variable_get("@#{o}")
            object.errors.collect { |e| errors << e[1] } unless object.errors.empty?
          end
        else
          if object_name.kind_of?(ActiveRecord::Base) || object_name.kind_of?(CouchModel) || object_name.kind_of?(Hash)
            object = object_name
          else
            object = instance_variable_get("@#{object_name}")
          end
          if object_name.kind_of?(CouchModel) || object_name.kind_of?(Hash)
            object.errors.collect { |e| errors << e } if object && !object.errors.empty?
          else
            object.errors.collect { |e| errors << e[1] } if object && !object.errors.empty?
          end
        end

        if object && !errors.empty?
          return content_tag("div",
            content_tag( options[:header_tag] || "h2",
              options[:message] || "You have erros in your form:" ) +
              content_tag("ul", errors.collect { |err| content_tag("li", err) }),
              "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
            )
        else
          ""
        end
      end
    private
      def custom_error_wrapper(object_name, property_name, tag_text)
        object = instance_variable_get("@#{object_name}")
        if object.respond_to?("errors") && object.errors.on(property_name)
          return "<div class='fieldWithErrors'>" + tag_text + "</div>" if object.errors.invalid?(property_name)
        end
        return tag_text
      end
    end
  end
end

