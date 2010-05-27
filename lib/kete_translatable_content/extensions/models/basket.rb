# extensions to the kete basket model

# require the model in Kete before reopening it below
Basket

class Basket
  def self.list_as_names_and_urlified_names
    basket_list = Array.new
    all(:select => 'id, name, urlified_name, locale, original_locale').each do |basket|
      translated_name = basket.name_translation_for(I18n.locale) || basket.name
      basket_list << [translated_name, basket.urlified_name]
    end
    basket_list
  end

  def additional_footer_content_with_inheritance
    value = parsed_value_from(self._configurable_settings.find_by_name('additional_footer_content'))
    value ||= parsed_value_from(self.site_basket._configurable_settings.find_by_name('additional_footer_content'))
    value
  end

  private

  def parsed_value_from(setting)
    if setting
      # Original translation values will come back as YAML, but translations are just strings
      value = (setting.original_locale == setting.locale) ? YAML.load(setting.value) : setting.value
      # If the value is blank, return nil, else return the value
      value.to_s.squish.present? ? value : nil
    else
      nil
    end
  end
end
