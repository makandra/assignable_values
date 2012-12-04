module AssignableValues
  module ActiveRecord
    module Restriction
      class SerializedArrayAttribute < ScalarAttribute
        
        def humanized_value(values, value)
          value.map{|v| super(values, v)}.join(separator)
        end
        
        def validate_value(record, values)
          if values.blank? && ! (allow_blank? || skip_blank?(record))
            record.errors.add(property, cant_be_blank_error_message)
          else
            values.each do |value|
              unless assignable_value?(record, value)
                record.errors.add(property, not_included_error_message)
              end
            end
          end
        end
                
        private
        
        def values_to_skip_validation(record)
          previously_saved_value(record) || []
        end
        
        # for multiple selections, allow_blank == true is a convenient default 
        def allow_blank?
          if @options.has_key?(:allow_blank)
            super
          else
            true
          end
        end
        
        # if the previous value was blank, we still want to stay with 
        # the default to skip validation for unchanged values
        def skip_blank?(record)
          return false if record.new_record?
          ! previously_saved_value(record).present?
        end
        
        def separator
          @options[:separator] || ', '
        end
        
      end
    end
  end
end
