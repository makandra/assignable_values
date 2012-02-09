module AssignableValues
  module ActiveRecord
    module Restriction
      class BelongsToAssociation < Base

        private

        def association_class
          model.reflect_on_association(property).klass
        end

        def association_id_method
          "#{property}_id"
        end

        def association_id(record)
          record.send(association_id_method)
        end

        def previously_saved_value(record)
          old_id = record.send("#{association_id_method}_was")
          association_class.find_by_id(old_id) if old_id
        end

        def current_value(record)
          value = record.send(property)
          value = record.send(property, true) if (value && value.id) != association_id(record)
          value
        end

      end
    end
  end
end
