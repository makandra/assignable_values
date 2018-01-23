module AssignableValues
  module ActiveRecord
    module Restriction
      class BelongsToAssociation < Base

        private

        def association_class
          model.reflect_on_association(property).klass
        end

        def association_id_method
          association = model.reflect_on_association(property)
          if association.respond_to?(:foreign_key)
            association.foreign_key # Rails >= 3.1
          else
            association.primary_key_name # Rails 2 + 3.0
          end
        end

        def error_property
          association_id_method
        end

        def association_id(record)
          record.send(association_id_method)
        end

        def has_previously_saved_value?(record)
          if record.respond_to?(:attribute_in_database)
            !record.new_record? # Rails >= 5.1
          else
            !record.new_record? && record.respond_to?(association_id_was_method) # Rails <= 5.0
          end
        end

        def previously_saved_value(record)
          if old_id = association_id_was(record)
            if old_id == association_id(record)
              current_value(record) # no need to query the database if nothing changed
            else
              association_class.find_by_id(old_id)
            end
          end
        end

        def current_value(record)
          record.send(property)
        end

        private

        def association_id_was(record)
          if record.respond_to?(:attribute_in_database)
            record.attribute_in_database(:"#{association_id_method}").presence # Rails >= 5.1
          else
            record.send(association_id_was_method).presence # Rails <= 5.0
          end
        end

        def association_id_was_method
          :"#{association_id_method}_was"
        end

      end
    end
  end
end


