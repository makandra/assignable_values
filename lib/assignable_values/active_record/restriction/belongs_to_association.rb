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

        def association_id
          send(association_id_method)
        end

        def previously_saved_value(record)
          old_id = record.send("#{association_id_method}_was")
          association_class.find(old_id) if old_id
        end

      end
    end
  end
end
