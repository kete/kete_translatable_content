require File.expand_path(File.dirname(__FILE__) + "/mongo_factories")


LOCALE_LABELS = { :en => "a label",
  :ar => "Ar_lable",
  :fi => "fi_lable",
  :fr => "fr_label",
  :zh => "zh_label"}



MongoMapper.database = 'test'

def translate_topic_type_for_locales(topic_type, locales)
  locales = [locales] unless locales.is_a?(Array)
  locales.each do |locale|
    I18n.locale = locale
    topic_type.translate(:name => LOCALE_LABELS[locale]).save
  end
end

