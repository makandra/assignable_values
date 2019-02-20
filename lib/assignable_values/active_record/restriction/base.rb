module AssignableValues
  module ActiveRecord
    module Restriction
      class Base

        attr_reader :model, :property, :options, :values, :default, :secondary_default

        def initialize(model, property, options, &values)
          @model = model
          @property = property
          @options = options
          @values = values
          ensure_values_given
          setup_default
          define_assignable_values_method
          setup_validation
        end

        def validate_record(record)
          value = current_value(record)
          unless allow_blank?(record) && value.blank?
            begin
              unless assignable_value?(record, value)
                record.errors.add(error_property, not_included_error_message)
              end
            rescue DelegateUnavailable
              # if the delegate is unavailable, the validation is skipped
            end
          end
        end

        def set_default(record)
          if record.new_record? && record.send(property).nil?
            default_value = evaluate_default(record, default)
            begin
              if secondary_default? && !assignable_value?(record, default_value)
                secondary_default_value = evaluate_default(record, secondary_default)
                if assignable_value?(record, secondary_default_value)
                  default_value = secondary_default_value
                end
              end
            rescue AssignableValues::DelegateUnavailable
              # skip secondary defaults if querying assignable values from a nil delegate
            end
            record.send("#{property}=", default_value)
          end
          true
        end

        def assignable_values(record, options = {})
          assignable_values = []
          current_values = assignable_values_from_record_or_delegate(record)

          if options.fetch(:include_old_value, true) && has_previously_saved_value?(record)
            old_value = previously_saved_value(record)
            if @options[:multiple]
              if old_value.is_a?(Array)
                assignable_values |= old_value
              end
            elsif !old_value.blank? && !current_values.include?(old_value)
              assignable_values << old_value
            end
          end

          assignable_values += current_values
          if options[:decorate]
            assignable_values = decorate_values(assignable_values)
          end
          assignable_values
        end

        private

        def error_property
          property
        end

        def not_included_error_message
          if @options[:message]
            @options[:message]
          else
            I18n.t('errors.messages.inclusion', :default => 'is not included in the list')
          end
        end

        def assignable_value?(record, value)
          if @options[:multiple]
            assignable_multi_value?(record, value)
          else
            assignable_single_value?(record, value)
          end
        end

        def assignable_single_value?(record, value)
          (has_previously_saved_value?(record) && value == previously_saved_value(record)) ||
            (value.blank? && allow_blank?(record)) ||
            assignable_values(record, :include_old_value => false).include?(value)
        end

        def assignable_multi_value?(record, value)
          (has_previously_saved_value?(record) && value == previously_saved_value(record)) ||
            (value.blank? ? allow_blank?(record) : subset?(value, assignable_values(record)))
        end

        def subset?(array1, array2)
          array1.is_a?(Array) && array2.is_a?(Array) && (array1 - array2).empty?
        end

        def evaluate_default(record, value_or_proc)
          if value_or_proc.is_a?(Proc)
            record.instance_exec(&value_or_proc)
          else
            value_or_proc
          end
        end

        def current_value(record)
          record.send(property)
        end

        def has_previously_saved_value?(record)
          raise NotImplementedError
        end

        def previously_saved_value(record)
          raise NotImplementedError
        end

        def decorate_values(values)
          values
        end

        def delegate?
          @options.has_key?(:through)
        end

        def default?
          @options.has_key?(:default)
        end

        def secondary_default?
          @options.has_key?(:secondary_default)
        end

        def allow_blank?(record)
          evaluate_option(record, @options[:allow_blank])
        end

        def delegate_definition
          options[:through]
        end

        def enhance_model_singleton(&block)
          @model.singleton_class.class_eval(&block)
        end

        def enhance_model(&block)
          @model.class_eval(&block)
        end

        def setup_default
          if default?
            @default = options[:default] # for attr_reader
            @secondary_default = options[:secondary_default] # for attr_reader
            ensure_after_initialize_callback_enabled
            restriction = self
            enhance_model do
              set_default_method = :"set_default_#{restriction.property}"
              define_method set_default_method do
                restriction.set_default(self)
              end
              after_initialize set_default_method
            end
          elsif secondary_default?
            raise AssignableValues::NoDefault, "cannot use the :secondary_default option without a :default option"
          end
        end

        def ensure_after_initialize_callback_enabled
          if active_record_2?
            enhance_model do
              # Old ActiveRecord version only call after_initialize callbacks only if this method is defined in a class.
              unless method_defined?(:after_initialize)
                define_method(:after_initialize) {}
              end
            end
          end
        end

        def active_record_2?
          ::ActiveRecord::VERSION::MAJOR < 3
        end

        def setup_validation
          restriction = self
          enhance_model do
            validate_method = :"validate_#{restriction.property}_assignable"
            define_method validate_method do
              restriction.validate_record(self)
            end
            validate validate_method.to_sym
          end
        end

        def define_assignable_values_method
          restriction = self
          enhance_model do
            assignable_values_method = :"assignable_#{restriction.property.to_s.pluralize}"
            define_method assignable_values_method do |*args|
              # Ruby 1.8.7 does not support optional block arguments :(
              options = args.first || {}
              options.merge!({:decorate => true})
              restriction.assignable_values(self, options)
            end
          end
        end

        def assignable_values_from_record_or_delegate(record)
          if delegate?
            assignable_values_from_delegate(record).to_a
          else
            record.instance_exec(&@values).to_a
          end
        end

        def delegate(record)
          evaluate_option(record, delegate_definition)
        end

        def evaluate_option(record, option)
          case option
          when NilClass, TrueClass, FalseClass then option
          when Symbol then record.send(option)
          when Proc then record.instance_exec(&option)
          else raise "Illegal option type: #{option.inspect}"
          end
        end

        def assignable_values_from_delegate(record)
          delegate = delegate(record)
          delegate.present? or raise DelegateUnavailable, "Cannot query a nil delegate for assignable values"
          delegate_query_method = :"assignable_#{model.name.underscore.gsub('/', '_')}_#{property.to_s.pluralize}"
          args = delegate.method(delegate_query_method).arity == 0 ? [] : [record]
          delegate.send(delegate_query_method, *args)
        end

        def ensure_values_given
          @values or @options[:through] or raise NoValuesGiven, 'You must supply the list of assignable values by either a block or :through option'
        end

      end
    end
  end
end

