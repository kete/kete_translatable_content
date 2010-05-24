ApplicationController.class_eval do
  def kete_translatable_content?
    controller, controller_as_key, action = params[:controller], params[:controller].singularize, params[:action]

    translatable = Kete.translatables[controller_as_key]
    return true if translatable && (translatable['views'] || []).include?(action)

    # for some translatables, the controller is different than (or in addition to) its key.pluralized
    !!Kete.translatables.find { |t|
      (t.last['controllers'] || []).include?(controller) && (t.last['views'] || []).include?(action)
    }
  end
  helper_method :kete_translatable_content?

  def current_translatable_record
    key = params[:controller].singularize
    instance_variable_get('@' + key) || @item || @record || key.camelize.constantize.find(params[:id])
  end
  helper_method :current_translatable_record

  before_filter :reload_standard_baskets
  def reload_standard_baskets
    Rails.logger.debug "[Kete Translatable Content]: Reloading Standard Baskets to be locale aware"
    [@site_basket, @help_basket, @about_basket, @documentation_basket].each { |b| b.reload }
  end

  before_filter :redirect_unless_editing_original_locale, :only => ['edit', 'section', 'appearance', 'homepage_options']
  def redirect_unless_editing_original_locale
    action = params[:action]
    editing_actions = ['edit', 'section', 'appearance', 'homepage_options']
    if kete_translatable_content? && editing_actions.include?(action)
      # check to see if we are in the special case for system settings
      if action == 'section' && I18n.locale.to_sym != I18n.default_locale.to_sym
        flash[:error] = I18n.t('kete_translatable.only_edit_original_locale')
        I18n.locale = I18n.default_locale
        return true
      elsif action != 'section'
        # handle everything else
        translated = current_translatable_record
        if I18n.locale.to_sym != translated.original_locale.to_sym
          flash[:error] = I18n.t('kete_translatable.only_edit_original_locale')
          redirect_to params.merge(:locale => translated.original_locale)
          return false
        end
      end
    end
    true
  end

  # override mongo_translatable's target_id locally
  def target_id(options = {})
    translated = options.delete(:id)
    basket_classes = [Feed, ConfigurableSetting]
    id = case translated.class
         when *basket_classes then translated.basket.id
         when SystemSetting then nil
         else translated
         end
  end

  # override mongo_translatable's target_action locally
  def target_action(options = {})
    translated = @translated || @translatable
    # relies on first view defined in Kete.translatables for a key
    # being the redirect to action
    key = translated.class.name.tableize.singularize

    target_action = case key
                    when 'system_setting' then 'index'
                    when 'configurable_setting' then 'appearance'
                    when 'feed' then 'homepage_options'
                    else options.delete(:action) || Kete.translatables[key]['views'].first
                    end
  end

  # override mongo_translatable's target_locale locally
  # because we only allow editing of the original locale (see redirect_unless_editing_original_locale)
  # make sure we redirect to a locale the user has access to after translations are created or saved
  def target_locale(options = {})
    translated = @translated || @translatable
    override_locale = translated.original_locale
    override_locale || options.delete(:locale) || (@translation.locale if @translation) || I18n.locale
  end

  # override mongo_translatable's target_controller locally
  # some kete translatables don't fall back under their own controller
  def target_controller(options = {})
    controller = options.delete(:controller)
    if controller.nil?
      key = options.delete(:translatable_params_name)
      if Kete.translatables[key] && Kete.translatables[key]['controllers'].present?
        controller = Kete.translatables[key]['controllers'].first
      else
        controller = key.pluralize
      end
    end
  end
end
