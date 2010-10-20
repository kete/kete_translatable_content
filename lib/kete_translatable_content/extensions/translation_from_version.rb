require 'replace_results_with_translations'
require 'redefine_find_with_result_replacement'
# For classes where their ::Version subclass
# is what has mongo_translatable declaration is on
module TranslationFromVersion
  unless included_modules.include? TranslationFromVersion
    def self.included(base)
      base.extend(ReplaceResultsWithTranslations)
      base.extend(RedefineFindWithResultReplacement)
      base.extend(ClassMethods)
      base.extend(InstanceMethods)
    end

    # an instance of the ::Version subclass is what has a translation
    # mapped to it for instances of this class
    # these methods, if appropriate, pulls the translation for the requested locale
    # for the version of the original class instance
    module ClassMethods

    end
    module InstanceMethods

      #Get the current translation or the latest
      def translation_for(locale)
        translation = self.class::Translation.first(self.class.as_foreign_key_sym => id, :locale => locale, :version => self.version)
        translation ||= self.class::Translation.first(self.class.as_foreign_key_sym => id, :locale => locale)
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
          # TODO: locale's emptiness is the reported error
          # when this is triggered, figure out why
          # serving its purpose though to prevent a translation to be added for original_locale
          @translation.errors.replace(:locale, "Cannot add translation the same as the original locale.")
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
end
