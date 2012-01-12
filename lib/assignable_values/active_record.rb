module AssignableValues
  module ActiveRecord

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module ClassMethods

      private

      def assignable_values_for(property, &values)
        if belongs_to_association?(property)
          restrict_belongs_to_association(property, values)
        else
          restrict_scalar_attribute(property, values)
        end
      end

      def belongs_to_association?(association)
        reflection = reflect_on_association(association)
        reflection && reflection.macro == :belongs_to
      end

      def restrict_scalar_attribute(attribute, values)
        assignable_values_method = "assignable_#{attribute.pluralize}"
        validate_method = "validate_#{attribute}_assignable"
        singleton_class.send :define_method, assignable_values_method do
          instance_eval(&values).collect do |value|
            value = value.dup
            def value.human
              humanize_scalar_attribute_value(attribute, value)
            end
            value
          end
        end
        define_method validate_method do
          
        end
      end

      def restrict_belongs_to_association(name, values)

      end

      def humanize_scalar_attribute_value(attribute, value)
        I18n.t("assignable_values.#{name.underscore}.#{attribute}")
      end

    end

    module InstanceMethods

    end

  end
endd