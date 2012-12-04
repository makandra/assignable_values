require 'assignable_values/active_record/restriction/base'
require 'assignable_values/active_record/restriction/belongs_to_association'
require 'assignable_values/active_record/restriction/scalar_attribute'
require 'assignable_values/active_record/restriction/serialized_array_attribute'
module AssignableValues
  module ActiveRecord
    module Restriction
      class TypeFactory

        attr_reader :model
        
        def initialize(model)
          @model = model
        end
        
        def get(property)
          if belongs_to_association?(property)
            BelongsToAssociation
          elsif serialized_array?(property)
            SerializedArrayAttribute 
          else
            ScalarAttribute
          end
        end
        
        private
        
        def belongs_to_association?(property)
          reflection = model.reflect_on_association(property)
          reflection && reflection.macro == :belongs_to
        end
        
        def serialized_array?(property)
          serialization = model.serialized_attributes[property.to_s]
          if serialization.respond_to?(:object_class) # since rails 3.2
            serialization.object_class == Array
          else 
            serialization == Array
          end
        end

      end
    end
  end
end

