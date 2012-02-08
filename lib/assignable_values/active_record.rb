require 'assignable_values/active_record/belongs_to_association'
require 'assignable_values/active_record/scalar_attribute'

module AssignableValues
  module ActiveRecord

    include BelongsToAssociation
    include ScalarAttribute

    private

    def assignable_values_for(property, options = {}, &values)
      values or options[:through] or raise NoValuesGiven, 'You must supply the list of assignable values by either a block or :through option'
      setup_property_default(property, options[:default]) if options.has_key?(:default)
      values = setup_values_delegate(property, options[:through]) if options.has_key?(:through)
      if belongs_to_association?(property)
        restrict_belongs_to_association(property, options, &values)
      else
        restrict_scalar_attribute(property, options, &values)
      end
    end

    def authorize_values_for(property, options = {})
      method_defined?(:power) or attr_accessor :power
      assignable_values_for property, options.merge(:through => :power)
    end

    def setup_property_default(property, default)
      set_default_method = "set_default_#{property}"
      define_method set_default_method do
        if new_record? && send(property).nil?
          default = instance_eval(&default) if default.is_a?(Proc)
          send("#{property}=", default)
        end
        true
      end
      after_initialize set_default_method
    end

    def setup_values_delegate(property, delegate_method)
      assignable_values_from_delegate_method = "assignable_#{property.to_s.pluralize}_from_#{delegate_method}"
      define_method assignable_values_from_delegate_method do
        delegate = send(delegate_method) or raise DelegateUnavailable, "Cannot query a nil #{delegate_method} for assignable values"
        delegate_query_method = "assignable_#{self.class.name.underscore}_#{property.to_s.pluralize}"
        args = delegate.method(delegate_query_method).arity == 1 ? [self] : []
        delegate.send(delegate_query_method, *args)
      end
      lambda { send(assignable_values_from_delegate_method) }
    end

  end

end

ActiveRecord::Base.send(:extend, AssignableValues::ActiveRecord)

