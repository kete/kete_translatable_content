require 'mongo_translatable'
require 'kete_translatable_content'

config.to_prepare do
  ApplicationHelper.send(:include, TranslatablesHelper)
  ApplicationHelper.send(:include, KeteTranslatableContentHelper)
end

# precedence over a plugin or gem's (i.e. an engine's) app/views
# this is the way to go in most cases,
# but in our case we want to override the app's view.
# so we pop off our gem's app/views directory and put it at the front
kete_translatable_content_views_dir = File.join(directory, 'app/views')
# drop it from it's existing location if it exists
ActionController::Base.view_paths.delete kete_translatable_content_views_dir
# add it to the front of array
ActionController::Base.view_paths.unshift kete_translatable_content_views_dir
