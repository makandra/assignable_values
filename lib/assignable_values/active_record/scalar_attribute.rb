module AssignableValues
  module ActiveRecord
    module ScalarAttribute

      def restrict_scalar_attribute(attribute, options, &values)

        assignable_values_method = "assignable_#{attribute.to_s.pluralize}"
        validate_method = "validate_#{attribute}_assignable"
        #delegate_method = options[:through]
        #assignable_values_from_delegate_method = "assignable_#{attribute.to_s.pluralize}_from_#{delegate_method}"
        #
        #if delegate_method
        #  define_method assignable_values_from_delegate_method do
        #    delegate = send(delegate_method) or raise DelegateUnavailable, "Cannot query a nil #{delegate_method} for assignable values"
        #    delegate_query_method = "assignable_#{self.class.name.underscore}_#{attribute.to_s.pluralize}"
        #    args = delegate.method(delegate_query_method).arity == 1 ? [self] : []
        #    delegate.send(delegate_query_method, *args)
        #  end
        #end

        define_method assignable_values_method do
          assignable_values = []
          old_value = send("#{attribute}_was")
          assignable_values << old_value if old_value.present?
          assignable_values |= instance_eval(&values).to_a
          model_class = self.class
          assignable_values = assignable_values.collect do |value|
            if value.is_a?(String)
              value = value.dup
              value.singleton_class.send(:define_method, :human) do
                model_class.send(:humanize_scalar_attribute_value, attribute, value)
              end
            end
            value
          end
          assignable_values
        end

        define_method validate_method do
          value = send(attribute)
          unless options[:allow_blank] && value.blank?
            begin
              assignable_values = send(assignable_values_method)
              assignable_values.include?(value) or errors.add(attribute, I18n.t('disallowed_value'))
            rescue DelegateUnavailable
              # if the delegate is unavailable, the validation is skipped
            end
          end
        end
        validate validate_method
      end

      def humanize_scalar_attribute_value(attribute, value)
        I18n.t("assignable_values.#{name.underscore}.#{attribute}.#{value}", :default => value.humanize)
      end

    end
  end
end