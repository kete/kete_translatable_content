require File.join(File.dirname(__FILE__), '../tinymce_controller_valid_action_override')
require File.join(File.dirname(__FILE__), '../tagging_controller_overrides')

WebLinksController.class_eval do
  include TinymceControllerValidActionOverride
  include TaggingControllerOverrides
end
