module AssignableValues
  module ActiveRecord
    module Restriction
      class StoreAccessorAttribute < ScalarAttribute

        private

        def store_identifier
          @model.stored_attributes.find { |_, attrs| attrs.include?(property.to_sym) }&.first
        end

        def value_was_method
          :"#{store_identifier}_was"
        end

        def value_was(record)
          accessor = if record.respond_to?(:attribute_in_database) # Rails >= 5.1
            record.attribute_in_database(:"#{store_identifier}")
          else # Rails <= 5.0
            record.send(value_was_method)
          end

          accessor.with_indifferent_access[property]
        end

      end
    end
  end
end
