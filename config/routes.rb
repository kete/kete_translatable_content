require 'kete_translatable_content'

# extend routes for translations of kete content
ActionController::Routing::Routes.draw do |map|
  # translations routes
  # note that we don't want to override the standard routes handled below
  # restful index is the same as our normal index action, so we limit it to that
  TRANSLATABLES.each do |name, spec_hash|
    map.resources name.camelize.constantize.table_name.to_sym, :path_prefix => ':urlified_name', :only => [:index], :has_many => :translations
  end
end
