module AssignableValues
  module ActiveRecord
    module Restriction
      class ScalarAttribute < Base

        def initialize(*args)
          super
          define_humanized_method
        end

        def humanize_string_value(value)
          if value.present?
            dictionary_key = "assignable_values.#{model.name.underscore}.#{property}.#{value}"
            I18n.t(dictionary_key, :default => value.humanize)
          end
        end

        private

        def define_humanized_method
          restriction = self
          enhance_model do
            define_method "humanized_#{restriction.property}" do
              value = send(restriction.property)
              restriction.humanize_string_value(value)
            end
          end
        end

        def decorate_values(values)
          restriction = self
          values.collect do |value|
            if value.is_a?(String)
              value = value.dup
              value.singleton_class.send(:define_method, :humanized) do
                restriction.humanize_string_value(value)
              end
            end
            value
          end
        end

        def previously_saved_value(record)
          record.send("#{property}_was")
        end


      end
    end
  end
end
