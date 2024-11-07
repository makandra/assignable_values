module AssignableValues
  module ActiveRecord

    private

    def assignable_values_for(property, options = {}, &values)
      restriction_type = if belongs_to_association?(property)
        Restriction::BelongsToAssociation
      elsif store_accessor_attribute?(property)
        Restriction::StoreAccessorAttribute
      else
        Restriction::ScalarAttribute
      end

      restriction_type.new(self, property, options, &values)
    end

    def belongs_to_association?(property)
      reflection = reflect_on_association(property)
      reflection && reflection.macro == :belongs_to
    end

    def store_accessor_attribute?(property)
      store_identifier_of(property).present?
    end

    def store_identifier_of(property)
      stored_attributes.find { |_, attrs| attrs.include?(property.to_sym) }&.first
    end

  end
end

ActiveSupport.on_load(:active_record) do
  extend(AssignableValues::ActiveRecord)
end
