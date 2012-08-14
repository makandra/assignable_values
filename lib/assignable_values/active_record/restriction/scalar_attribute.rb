module AssignableValues
  module ActiveRecord
    module Restriction
      class ScalarAttribute < Base

        def initialize(*args)
          super
          define_humanized_value_method
          define_humanized_values_method
        end

        def humanized_value(value)
          if value.present?
            if @hardcoded_humanizations
              @hardcoded_humanizations[value]
            else
              dictionary_scope = "assignable_values.#{model.name.underscore}.#{property}"
              I18n.t(value, :scope => dictionary_scope, :default => default_humanization_for_value(value))
            end
          end
        end

        def humanized_values(record)
          assignable_values(record).collect do |value|
            HumanizedValue.new(value, humanized_value(value))
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
            @hardcoded_humanizations = values
            values = values.keys
          else
            super
          end
        end

        def define_humanized_value_method
          restriction = self
          enhance_model do
            define_method "humanized_#{restriction.property}" do |*args|
              given_value = args[0]
              value = given_value || send(restriction.property)
              restriction.humanized_value(value)
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
              value = value.dup
              value.singleton_class.send(:define_method, :humanized) do
                restriction.humanized_value(value)
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
