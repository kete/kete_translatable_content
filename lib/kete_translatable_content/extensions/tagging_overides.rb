module TaggingOverides
  unless included_modules.include? TaggingOverides
    def self.included(klass)
      klass.class_eval do
        alias :public_tags_orig :public_tags
        def public_tags
          Tag.swap_in_translation_for_multiple(public_tags_orig)
        end

        alias :private_tags_orig :private_tags
        def private_tags
          Tag.swap_in_translation_for_multiple(private_tags_orig)
        end
      end
    end
  end
end
