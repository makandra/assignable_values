module AssignableValues
  module ActiveRecord
    module BelongsToAssociation

      def belongs_to_association?(association)
        reflection = reflect_on_association(association)
        reflection && reflection.macro == :belongs_to
      end

      def restrict_belongs_to_association(name, values)
        raise 'implement me'
      end

    end
  end
end

