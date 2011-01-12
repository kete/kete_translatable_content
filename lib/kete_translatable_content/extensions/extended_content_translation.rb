# for ZOOM_CLASSES, extended_content is translatable_attribute
# however, in mongodb we store indivdual values for the extended fields
# and then we swap in actual translatable extended field values via individual
# extended field setter methods (method missing methods)
# the advantage is that we only have to tell mongo_translatable that extended_content
# is translatable at the time of system startup
# and we can go on declaring new extended fields dynamically
module ExtendedContentTranslation
  unless included_modules.include? ExtendedContentTranslation
    def self.included(base)

      #Send define method because scopes are not playing nicely together
      base.send(:define_method, :translatable_attributes) do
        return @translatable_attributes if @translatable_attributes.present?

        # klass is ::Version classes parent namespace wise
        klass = self.class

        type = klass == Topic ? topic_type : ContentType.find_by_class_name(klass.name)

        if type
          # fields = type.mapped_fields.select { |f| ['text', 'textarea', 'choice', 'autocomplete'].include?(f.ftype) }
          fields = type.mapped_fields.select { |f| ['text', 'textarea',].include?(f.ftype) }

          type_translatable_attributes = fields.collect do |f|
            unless f.multiple
              f.label_for_params.to_sym
            else
              [f.label_for_params.to_sym, Array]
            end
          end

          klass::Translation.update_keys_if_necessary_with(type_translatable_attributes)

          update_translation_for_methods_if_necessary_with(type_translatable_attributes)

          type_translatable_attribute_keys_only = type_translatable_attributes.collect do |a|
            if a.is_a?(Array)
              a[0]
            else
              a
            end
          end

          @translatable_attributes = self.class.translatable_attributes + type_translatable_attribute_keys_only
        else
          @translatable_attributes = self.class.translatable_attributes
        end
        @translatable_attributes
      end
    end
  end
end

