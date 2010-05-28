# Redefines public_tags and private_tags to translate the returned tag objects
# Make sure these are only done when the class they are being included into already responds
# to public_tags, otherwise it'll end up trying to alias a method that doesn't exist

module TaggingOverides
  unless included_modules.include? TaggingOverides
    def self.included(klass)
      klass.class_eval do

        if self.new.respond_to?(:public_tags)
          alias_method(:public_tags_orig, :public_tags) unless self.new.respond_to?(:public_tags_orig)
          def public_tags
            Tag.swap_in_translation_for_multiple(public_tags_orig)
          end
        end

        if self.new.respond_to?(:private_tags)
          alias_method(:private_tags_orig, :private_tags) unless self.new.respond_to?(:private_tags_orig)
          def private_tags
            Tag.swap_in_translation_for_multiple(private_tags_orig)
          end
        end

      end
    end
  end
end
