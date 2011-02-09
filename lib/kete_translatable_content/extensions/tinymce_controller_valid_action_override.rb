# this is necessary for translate ajax lighbox to be able to use tinymce
# for description attribute
# for ITEM_CLASSES
module TinymceControllerValidActionOverride
  unless included_modules.include? TinymceControllerValidActionOverride
    def self.included(klass)
      def add_show_as_uses_tiny_mce
        instance_variable_set(:@uses_tiny_mce, true)
      end

      private :add_show_as_uses_tiny_mce

      klass.send :before_filter, :add_show_as_uses_tiny_mce, :only => [:show]
    end
  end
end
