module AssignableValues
  module ActiveRecord

    private

    def assignable_values_for(property, options = {}, &values)
      restriction_type = belongs_to_association?(property) ? Restriction::BelongsToAssociation : Restriction::ScalarAttribute
      restriction_type.new(self, property, options, &values)
    end

    #def authorize_values_for(property, options = {})
    #  method_defined?(:power) or attr_accessor :power
    #  assignable_values_for property, options.merge(:through => :power)
    #end

    def belongs_to_association?(property)
      reflection = reflect_on_association(property)
      reflection && reflection.macro == :belongs_to
    end

  end
end

ActiveRecord::Base.send(:extend, AssignableValues::ActiveRecord)

