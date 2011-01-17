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
    key = case params[:controller]
          when 'images'
            'still_image'
          when 'audio'
            'audio_recording'
          else
            params[:controller].singularize
          end
    
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

  # override mongo_translatable's target_locale locally
  # because we only allow editing of the original locale (see redirect_unless_editing_original_locale)
  # make sure we redirect to a locale the user has access to after translations are created or saved
  def target_locale(options = {})
    translation = options.delete(:translation) || @translation
    translated = @translated || @translatable
    override_locale = translated.original_locale if translated
    override_locale || options.delete(:locale) || (translation.locale if translation) || I18n.locale
  end

  # override mongo_translatable's target_controller locally
  # some kete translatables don't fall back under their own controller
  def target_controller(options = {})
    controller = options.delete(:controller)
    if controller.nil?
      key = options.delete(:translatable_params_name) || @translatable_params_name
      if Kete.translatables[key] && Kete.translatables[key]['controllers'].present?
        controller = Kete.translatables[key]['controllers'].first
      else
        controller = key.pluralize
      end
    end

    if controller == 'tags'
      if session[:original_item_return_to] && params[:action] == 'create'
        url_parts = session[:original_item_return_to].split('/')
        matching_parts = url_parts.select { |part| item_controllers.include?(part) }
        controller = matching_parts.first
      end
    end

    controller
  end

  # override mongo_translatable's target_action locally
  # some kete translatables don't fall back under their own action
  def target_action(options = {})
    translated = options.delete(:translated) || @translated || options.delete(:translatable) || @translatable

    case translated.class.name
    when 'SystemSetting'       then 'index'
    when 'Feed'                then 'homepage_options'
    when 'ConfigurableSetting'
      case translated.configurable_type
      when 'Basket'
        'appearance'
      end
    else
      key = translated.class.name.tableize.singularize
      if Kete.translatables[key] && Kete.translatables[key]['views'].present?
        Kete.translatables[key]['views'].first
      else
        options.delete(:action) || params[:action]
      end
    end
  end

  # override mongo_translatable's target_id locally
  # some kete translatables don't fall back under their own id
  def target_id(options = {})
    translated = options.delete(:translated) || @translated || options.delete(:translatable) || @translatable

    case translated.class.name
    when 'SystemSetting' then nil
    when 'Feed' then translated.basket_id
    when 'ConfigurableSetting' then translated.configurable_id
    when 'Tag'
      if session[:original_item_return_to] && params[:action] == 'create'
        id_segment = session[:original_item_return_to].split('/').last
        id = id_segment.include?('?') ? id_segment.split('?').first : id_segment
      else
        options.delete(:id) || translated
      end
    else
      options.delete(:id) || translated
    end
  end
  
  alias_method(:oai_dc_first_element_for_orig, :oai_dc_first_element_for) unless self.new.respond_to?(:oai_dc_first_element_for_orig)
  # we override to get the current locale's specific field value
  # if available
  def oai_dc_first_element_for(field_name, oai_dc)
    first_field_element = oai_dc.xpath(".//dc:#{field_name}[@xml:lang=\"#{I18n.locale}\"]",
                                       "xmlns:dc" => "http://purl.org/dc/elements/1.1/").first
    
    # we have a match for the locale, we're done
    return first_field_element if first_field_element.present?
      
    # no match, return first match without lang specified
    oai_dc.xpath(".//dc:#{field_name}",
                 "xmlns:dc" => "http://purl.org/dc/elements/1.1/").first
  end

  before_filter :set_original_item_return_to, :only => :show
  def set_original_item_return_to
    if item_controllers.include?(params[:controller])
      session[:original_item_return_to] = request.request_uri
    end
  end

  before_filter :add_locale_to_attributes_in_params, :only => [:create, :update]

  def add_locale_to_attributes_in_params
    # only relevant to Kete.translatables
    # return true if not Kete.translatables
    params_attributes_key = nil
    Kete.translatables.keys.each do |key|
      if params.keys.include?(key)
        params_attributes_key = key.to_sym
        break
      end
    end

    return true unless params_attributes_key

    if params[params_attributes_key].present?  &&
        params[params_attributes_key][:locale].blank?
      params[params_attributes_key][:locale] = I18n.locale
    end
    true
  end

  private :add_locale_to_attributes_in_params
end
