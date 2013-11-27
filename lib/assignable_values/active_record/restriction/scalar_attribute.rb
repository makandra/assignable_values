module AssignableValues
  module ActiveRecord
    module Restriction
      class ScalarAttribute < Base

        def initialize(*args)
          super
          define_humanized_value_method
          define_humanized_values_method
        end

        def humanized_value(values, value) # we take the values because that contains the humanizations in case humanizations are hard-coded as a hash
          if value.present?
            if values.respond_to?(:humanizations)
              values.humanizations[value]
            else
              dictionary_scope = "assignable_values.#{model.name.underscore}.#{property}"
              I18n.t(value, :scope => dictionary_scope, :default => default_humanization_for_value(value))
            end
          end
        end

        def humanized_values(record)
          values = assignable_values(record)
          values.collect do |value|
            HumanizedValue.new(value, humanized_value(values, value))
          end
        end

        private

        def default_humanization_for_value(value)
          if value.is_a?(String)
            value.humanize
          else
            value.to_s
          end
        end

        def parse_values(values)
          if values.is_a?(Hash)
            { :values => values.keys,
              :humanizations => values }
          else
            super
          end
        end

        def define_humanized_value_method
          restriction = self
          enhance_model do
            define_method "humanized_#{restriction.property}" do |*args|
              values = restriction.assignable_values(self)
              given_value = args[0]
              value = given_value || send(restriction.property)
              restriction.humanized_value(values, value)
            end
          end
        end

        def define_humanized_values_method
          restriction = self
          enhance_model do
            define_method "humanized_#{restriction.property.to_s.pluralize}" do
              restriction.humanized_values(self)
            end
          end
        end

        def decorate_values(values)
          restriction = self
          values.collect do |value|
            if value.is_a?(String)
              humanization = restriction.humanized_value(values, value)
              value = HumanizableString.new(value, humanization)
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
