require 'test_helper'
require 'mongo_test_helper'

# test that the oai dc helpers we use are overridden
# to return translations as well as locale's xml:lang
class KeteTranslatableContentOaiDcHelpersTest < ActiveSupport::TestCase
  
  zoom_translatables = Array.new
  Kete.translatables.each { |k,v| zoom_translatables << k.camelize if v['through_version'] }

  zoom_translatables.each do |zoom_class|

    context "#{zoom_class.humanize}" do
      setup do
        I18n.locale = I18n.default_locale
        
        item_for(zoom_class)

        create_translations_for(@item, [:title, :description])
      end

      should "return xml for title in original locale plus all translated titles" do
        builder = Nokogiri::XML::Builder.new
        builder.root do |xml|
          @item.oai_dc_xml_dc_title(xml)
        end
        assert builder.to_stripped_xml.include?("<dc:title xml:lang=\"#{I18n.default_locale}\">Item</dc:title>")
        ALL_TRANSLATION_LOCALE_KEYS_EXCEPT_EN.each do |key|
          assert builder.to_stripped_xml.include?("<dc:title xml:lang=\"#{key.to_s}\">#{LOCALE_LABELS[key]}</dc:title>")
        end
      end

      should "return xml for description in original locale plus all translated descriptions" do
        builder = Nokogiri::XML::Builder.new
        builder.root do |xml|
          @item.oai_dc_xml_dc_description(xml)
        end
        assert builder.to_stripped_xml.include?("<dc:description xml:lang=\"#{I18n.default_locale}\"><![CDATA[Description]]></dc:description>")
        ALL_TRANSLATION_LOCALE_KEYS_EXCEPT_EN.each do |key|
          assert builder.to_stripped_xml.include?("<dc:description xml:lang=\"#{key.to_s}\"><![CDATA[#{LOCALE_LABELS[key]}]]></dc:description>")
        end
      end

      should "return xml for tags in original locale plus all translated tags" do
        @item.tag_list << "tag"
        @item.save
        @item.reload
        @item.add_as_contributor(User.first, @item.version)

        # translate tag
        tag = @item.tags.first
        create_translations_for(tag, [:name])

        builder = Nokogiri::XML::Builder.new
        builder.root do |xml|
          @item.oai_dc_xml_tags_to_dc_subjects(xml)
        end
        assert builder.to_stripped_xml.include?("<dc:subject xml:lang=\"#{I18n.default_locale}\"><![CDATA[tag]]></dc:subject>")

        ALL_TRANSLATION_LOCALE_KEYS_EXCEPT_EN.each do |key|
          assert builder.to_stripped_xml.include?("<dc:subject xml:lang=\"#{key.to_s}\"><![CDATA[#{LOCALE_LABELS[key]}]]></dc:subject>")
        end
      end
    end
  end
end
