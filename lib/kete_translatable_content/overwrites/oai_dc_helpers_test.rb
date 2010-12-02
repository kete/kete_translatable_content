# overwrites for test/unit/oai_dc_helpers_test.rb
HasValue.oai_dc_helpers_title_xml = "\"\#\{if zoom_class == 'Comment' then '<dc:title>Item</dc:title>' else '<dc:title xml:lang=\"' + I18n.default_locale.to_s + '\"' + '>Item</dc:title>' end\}\""
HasValue.oai_dc_helpers_description_xml_when_only_xml = "\"\#\{if zoom_class == 'Comment' then '<dc:description><![CDATA[Description]]></dc:description>' else '<dc:description xml:lang=\"' + I18n.default_locale.to_s + '\"' + '><![CDATA[Description]]></dc:description>' end\}\""
HasValue.oai_dc_helpers_short_summary_xml_when_only_xml = "\"<dc:description xml:lang=\"\#\{I18n.default_locale\}\"><![CDATA[Short Summary]]></dc:description>\""
HasValue.oai_dc_helpers_tags_xml = "\"<dc:subject xml:lang=\"\#\{I18n.default_locale\}\"><![CDATA[tag]]></dc:subject>\""

