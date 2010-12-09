# Redefines methods in ZoomSearch module
module ZoomSearchOverrides
  unless included_modules.include? ZoomSearchOverrides
    def self.included(klass)
      klass.class_eval do

        if self.new.respond_to?(:query_options)
          alias_method(:query_options_orig, :query_options) unless self.new.respond_to?(:query_options_orig)
          # TEMPORARY
          # drop :element_set_name => "oai-kete-short"}
          # so we get the full record back
          def query_options
            logger.debug("in query_options override")
            { :query => @search.pqf_query.to_s,
              :existing_connection => @zoom_connection,
              :element_set_name => "oai" }
          end
        end

        if self.new.respond_to?(:oai_dc_first_element_for)
          alias_method(:oai_dc_first_element_for_orig, :oai_dc_first_element_for) unless self.new.respond_to?(:oai_dc_first_element_for_orig)
          # we override to get the current locale's specific field value
          # if available
          def oai_dc_first_element_for(field_name, oai_dc)
            logger.debug("locale is: " + I18n.locale.inspect)
            first_field_element = oai_dc.xpath(".//dc:#{field_name}[@xml:lang=\"#{I18n.locale}\"]", "xmlns:dc" => "http://purl.org/dc/elements/1.1/").first

            # we have a match for the locale, we're done
            return first_field_element if first_field_element.present?
            
            # no match, return first match without lang specified
            oai_dc.xpath(".//dc:#{field_name}", "xmlns:dc" => "http://purl.org/dc/elements/1.1/").first
          end
        end

      end
    end
  end
end
