require File.join(File.dirname(__FILE__), '../tinymce_controller_valid_action_override')

TopicsController.class_eval do
  include TinymceControllerValidActionOverride
end
