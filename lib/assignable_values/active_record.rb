module AssignableValues
  module ActiveRecord

    private

    def assignable_values_for(property, options = {}, &values)
      restriction_type = Restriction.type_for(self, property)
      restriction_type.new(self, property, options, &values)
    end

  end
end

ActiveRecord::Base.send(:extend, AssignableValues::ActiveRecord)

