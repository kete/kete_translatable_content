# supports extendeding kete's models for translation
# everything from basket names to topic titles
# Also extends application controller to reload baskets
# so that they are locale aware

require 'kete_translatable_content'

TRANSLATABLES.each do |name, spec_hash|
  name.camelize.constantize.send(:mongo_translate, spec_hash['translatable_attributes'])
end

ApplicationController.class_eval do
  def reload_standard_baskets
    Rails.logger.info "[Kete Translatable Content]: Reloading Standard Baskets to be locale aware"
    @site_basket.reload
    @help_basket.reload
    @about_basket.reload
    @documentation_basket.reload
  end
end

ApplicationController.send(:before_filter, :reload_standard_baskets)
