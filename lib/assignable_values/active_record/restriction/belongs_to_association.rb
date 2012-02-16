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
          if old_id = record.send("#{association_id_method}_was")
            if old_id == association_id(record)
              current_value(record) # no need to query the database if nothing changed
            else
              association_class.find_by_id(old_id)
            end
          end
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


