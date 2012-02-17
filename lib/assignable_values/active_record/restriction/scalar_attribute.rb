module AssignableValues
  module ActiveRecord
    module Restriction
      class ScalarAttribute < Base

        private

        def decorate_values(values)
          restriction = self
          values.collect do |value|
            if value.is_a?(String)
              value = value.dup
              value.singleton_class.send(:define_method, :human) do
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
