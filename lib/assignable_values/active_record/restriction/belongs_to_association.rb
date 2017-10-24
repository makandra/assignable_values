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
          !record.new_record? && record.respond_to?(association_id_was_method)
        end

        def previously_saved_value(record)
          if old_id = record.send(association_id_was_method).presence
            if old_id == association_id(record)
              current_value(record) # no need to query the database if nothing changed
            else
              association_class.find_by_id(old_id)
            end
          end
        end

        def current_value(record)
          value = record.send(property)
          value = value.reload if !value.nil? && !value.new_record? && (value && value.id) != association_id(record)
          value
        end

        private

        def association_id_was_method
          :"#{association_id_method}_was"
        end

      end
    end
  end
end


