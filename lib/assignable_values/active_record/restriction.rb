module AssignableValues
  module ActiveRecord
    module Restriction
      
      def self.type_for(model, property)
        factory = TypeFactory.new(model)
        factory.get(property)
      end
            
    end
  end
end

