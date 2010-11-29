# redefine helpers to include translated versions
module OaiDcHelpersOverrides
  unless included_modules.include? OaiDcHelpersOverrides
    def self.included(klass)
      klass.class_eval do

        if self.new.respond_to?(:oai_dc_xml_dc_title)
          alias_method(:oai_dc_xml_dc_title_orig, :oai_dc_xml_dc_title) unless self.new.respond_to?(:oai_dc_xml_dc_title_orig)

          def oai_dc_xml_dc_title(xml, options = {})
            is_translatable = Kete.translatables.keys.include?(self.class.name.tableize.singularize)

            # handle original title
            options = options.merge({ "xml:lang" => locale }) if is_translatable
            oai_dc_xml_dc_title_orig(xml, options)

            original_title = title

            return unless is_translatable

            @translations_for_this_version ||= self.class::Translation.all(self.class.as_foreign_key_sym => id,
                                                                           :version => version.to_s)
            @translations_for_this_version.each do |t|
              if t.title.present?
                self.title = t.title
                options = options.merge({ "xml:lang" => t.locale })
                oai_dc_xml_dc_title_orig(xml, options)
              end
            end
            self.title = original_title
          end
        end

        if self.new.respond_to?(:oai_dc_xml_dc_description)
          alias_method(:oai_dc_xml_dc_description_orig, :oai_dc_xml_dc_description) unless self.new.respond_to?(:oai_dc_xml_dc_description_orig)

          def oai_dc_xml_dc_description(xml, passed_description = nil, options = {})
            unless passed_description.blank?
              oai_dc_xml_dc_description_orig(xml, passed_description, options)
            else
              class_name = self.class.name
              is_translatable = Kete.translatables.keys.include?(class_name.tableize.singularize)
              has_short_summary = [Topic, Document].include?(self.class)

              options = options.merge({ "xml:lang" => locale }) if is_translatable

              # topic/document specific
              # order is important, first description will be used as blurb
              # in result list
              if has_short_summary && short_summary.present?
                oai_dc_xml_dc_description(xml, short_summary, options)
              end

              oai_dc_xml_dc_description(xml, description, options) if description.present?

              return unless is_translatable

              @translations_for_this_version ||= self.class::Translation.all(self.class.as_foreign_key_sym => id,
                                                                           :version => version.to_s)
              @translations_for_this_version.each do |t|
                options = options.merge({ "xml:lang" => t.locale })

                if has_short_summary && t.short_summary.present?
                  oai_dc_xml_dc_description(xml, t.short_summary, options)
                end

                if t.description.present?
                  options = options.merge({ "xml:lang" => t.locale })
                  oai_dc_xml_dc_description(xml, t.description, options)
                end
              end
            end
          end
        end

      end
    end
  end
end
