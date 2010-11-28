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

      end
    end
  end
end
