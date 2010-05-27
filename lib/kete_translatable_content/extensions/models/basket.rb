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
end
