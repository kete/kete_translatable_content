# For classes where their ::Version subclass
# is what has mongo_translatable declaration is on
module TranslationFromVersion
  unless included_modules.include? TranslationFromVersion

    # sometimes all you need is only the locales of translations
    # because of versioning we need to split out duplicates
    def translations_locales
      translations = self.class::Translation.all(self.class.as_foreign_key_sym => id,
                                                 :select => 'locale')
      uniq_translations = []
      translations.each do |trans|
        uniq_translations << trans unless uniq_translations.collect(&:locale).include?(trans.locale)
      end
      uniq_translations
    end

    # Get the current translation or the latest
    def translation_for(locale)
      translation = self.class::Translation.first(self.class.as_foreign_key_sym => id,
                                                  :locale => locale,
                                                  :version => self.version.to_s)
      translation ||= self.class::Translation.first(self.class.as_foreign_key_sym => id,
                                                    :locale => locale)
      return translation
    end

    def translate(options = {})
      translation_locale = options[:locale] || I18n.locale

      @translation = self.class::Translation.new({
        :locale => translation_locale,
        :translatable_locale => self.locale, # save original locale
        self.class.as_foreign_key_sym => id,
        :version => self.version
      })

      if translation_locale.to_s == original_locale.to_s
        # prevent a translation to be added for original_locale
        @translation.errors.replace(:locale,
                                    "Cannot add translation the same as the original locale.")
      else
        # work through self and replace attributes
        # with the passed in translations for defined translatable_attributes
        translatable_attributes.each do |translated_attribute|
          translated_value = options[translated_attribute]
          @translation.send("#{translated_attribute.to_sym}=", translated_value) if translated_value.present?
        end
      end

      @translation
    end
  end
end
