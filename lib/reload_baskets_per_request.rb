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
