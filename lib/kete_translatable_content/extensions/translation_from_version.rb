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
    end
    
    # an instance of the ::Version subclass is what has a translation
    # mapped to it for instances of this class
    # these methods, if appropriate, pulls the translation for the requested locale
    # for the version of the original class instance
    module ClassMethods
      
    end
  end
end
