# this is necessary for translate ajax lighbox to be able to use tinymce
# for description attribute
# for ITEM_CLASSES
module TinymceControllerValidActionOverride
  unless included_modules.include? TinymceControllerValidActionOverride
    def self.included(klass)
      all_valid_tinymce_actions = VALID_TINYMCE_ACTIONS + ['show']
      klass.send :uses_tiny_mce, :only => all_valid_tinymce_actions
    end
  end
end
