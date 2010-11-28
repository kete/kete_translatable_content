require File.expand_path(File.dirname(__FILE__) + "/mongo_factories")


LOCALE_LABELS = { :en => "a label",
  :ar => "Ar_lable",
  :fi => "fi_lable",
  :fr => "fr_label",
  :zh => "zh_label"}

ALL_TRANSLATION_LOCALE_KEYS_EXCEPT_EN = LOCALE_LABELS.keys - [:en]

MongoMapper.database = 'test'

def translate_topic_type_for_locales(topic_type, locales)
  create_translations_for(topic_type, [:name], locales)
end

def create_translations_for(item, attrs_to_mock = [:title], locales = nil)
  original_locale = I18n.locale

  locales ||= ALL_TRANSLATION_LOCALE_KEYS_EXCEPT_EN
  locales = [locales] unless locales.is_a?(Array)
  locales.each do |locale|
    I18n.locale = locale
    
    attrs = Hash.new
    attrs_to_mock.each do |attr_sym|
      attrs[attr_sym] = LOCALE_LABELS[locale]
    end

    item.translate(attrs).save
  end

  I18n.locale = original_locale
end


