module AssignableValues
  module ActiveRecord
    module Restriction
      class ScalarAttribute < Base

        def initialize(*args)
          super
          define_humanized_value_instance_method
          define_humanized_value_class_method
          define_humanized_assignable_values_instance_method
        end

        def humanized_value(klass, value)
          if value.present?
            humanization_from_i18n(klass, value) || default_humanization_for_value(value)
          end
        end

        def humanized_assignable_values(record, options = {})
          values = assignable_values(record, options)
          values.collect do |value|
            HumanizedValue.new(value, humanized_value(record.class, value))
          end
        end

        private

        def humanization_from_i18n(klass, value)
          klass.lookup_ancestors.select(&:name).find do |klass|
            dictionary_scope = :"assignable_values.#{klass.model_name.i18n_key}.#{property}"
            translation = I18n.translate(value, scope: dictionary_scope, default: nil)
            break translation unless translation.nil?
          end
        end

        def default_humanization_for_value(value)
          if value.is_a?(String)
            value.humanize
          else
            value.to_s
          end
        end

        def define_humanized_value_class_method
          restriction = self
          enhance_model_singleton do
            define_method :"humanized_#{restriction.property.to_s.singularize}" do |given_value|
              restriction.humanized_value(self, given_value)
            end
          end
        end

        def define_humanized_value_instance_method
          restriction = self
          multiple = @options[:multiple]
          enhance_model do
            define_method :"humanized_#{restriction.property.to_s.singularize}" do |*args|
              if args.size > 1 || (multiple && args.size == 0)
                raise ArgumentError.new("wrong number of arguments (#{args.size} for #{multiple ? '1' : '0..1'})")
              end
              given_value = args[0]
              value = given_value || send(restriction.property)
              restriction.humanized_value(self.class, value)
            end

            if multiple
              define_method :"humanized_#{restriction.property}" do
                values = send(restriction.property)
                if values.respond_to?(:map)
                  values.map do |value|
                    restriction.humanized_value(self.class, value)
                  end
                else
                  values
                end
              end
            end
          end
        end

        def define_humanized_assignable_values_instance_method
          restriction = self
          enhance_model do
            define_method :"humanized_assignable_#{restriction.property.to_s.pluralize}" do |*args|
              restriction.humanized_assignable_values(self, *args)
            end
          end
        end

        def has_previously_saved_value?(record)
          if record.respond_to?(:attribute_in_database) # Rails >= 5.1
            !record.new_record?
          else # Rails <= 5.0
            !record.new_record? && record.respond_to?(value_was_method)
          end
        end

        def previously_saved_value(record)
          value_was(record)
        end

        def value_was(record)
          if record.respond_to?(:attribute_in_database) # Rails >= 5.1
            record.attribute_in_database(:"#{property}")
          else # Rails <= 5.0
            record.send(value_was_method)
          end
        end

        def value_was_method
          :"#{property}_was"
        end

      end
    end
  end
end
