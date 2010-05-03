# require 'kete_translatable_content'
# supports extendeding kete's models for translation
# everything from basket names to topic titles
module ConfigureKeteContentTranslation
  unless included_modules.include? ConfigureKeteContentTranslation
    def extend_with_translatable_attributes(klass, translatable_attributes)
      klass.send :mongo_translate, translatable_attributes
    end
  end
end

