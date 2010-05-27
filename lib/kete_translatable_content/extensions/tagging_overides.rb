module TaggingOverides
  unless included_modules.include? TaggingOverides
    def self.included(klass)
      klass.class_eval do

        alias_method(:public_tags_orig, :public_tags) unless self.new.respond_to?(:public_tags_orig)
        def public_tags
          Tag.swap_in_translation_for_multiple(public_tags_orig)
        end

        alias_method(:private_tags_orig, :private_tags) unless self.new.respond_to?(:private_tags_orig)
        def private_tags
          Tag.swap_in_translation_for_multiple(private_tags_orig)
        end

      end
    end
  end
end
