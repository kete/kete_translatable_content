require 'mongo_translatable'
require 'kete_translatable_content'
# we do this here because we need it sooner
# other extensions as the are declared later
require 'translatable_content/extensions/kete'

config.to_prepare do
  kete_translatable_content_ready = true
  Kete.translatables.keys.each do |name|
    translatable = name.camelize.constantize.send(:new) rescue false
    kete_translatable_content_ready = translatable && translatable.respond_to?(:original_locale)
    break if kete_translatable_content_ready == false
  end

  # In development/production, we want to only setup stuff if IS_CONFIGURED is true
  # In test mode however, we always want to have it, since IS_CONFIGURED won't be true
  # at this stage, but it will be changed to true after Rails initializes.
  if (IS_CONFIGURED || Rails.env.test?) && kete_translatable_content_ready
    Kete.translatables.each do |name, options|
      args = [:mongo_translate, *options['translatable_attributes']]
      args << { :redefine_find => options['redefine_find'] } unless options['redefine_hash'].nil?
      name.camelize.constantize.send(*args)
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

    # load our locales
    I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.{rb,yml}') ]

    ApplicationController.class_eval do
      def kete_translatable_content?
        controller = params[:controller]
        controller_as_key = controller.singularize
        action = params[:action]

        return true if Kete.translatables[controller_as_key] &&
          Kete.translatables[controller_as_key]['views'] &&
          Kete.translatables[controller_as_key]['views'].include?(action)


        # for some translatables,
        # the controller is different than (or in addition to) its key.pluralized
        valid = false
        translatables_with_controller = Kete.translatables.select { |t| t.last['controller'].present? }
        translatables_with_controller.each do |name, options|
          controller_valid = true if options['controller'] == controller
          
          if controller_valid
            valid = true if options['views'].include?(action)
          end
        end
        valid
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
        @site_basket.reload
        @help_basket.reload
        @about_basket.reload
        @documentation_basket.reload
      end

      before_filter :redirect_unless_editing_original_locale, :only => ['edit', 'section']
      def redirect_unless_editing_original_locale
        if kete_translatable_content? && (params[:action] == 'edit' || params[:action] == 'section')
          # check to see if we are in the special case for system settings
          if params[:action] == 'section' && I18n.locale != I18n.default_locale
            flash[:error] = I18n.t('kete_translatable.only_edit_original_locale')
            I18n.locale = I18n.default_locale
            return true
          else
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

      # override mongo_translatable's target_action locally
      def target_action(options = {})
        translated = @translated || @translatable
        # relies on first view defined in Kete.translatables for a key
        # being the redirect to action
        key = translated.class.name.tableize.singularize
        target_action = options.delete(:action) || Kete.translatables[key]['views'].first
        target_action = 'index' if key == 'system_setting'
        target_action
      end

      # override mongo_translatable's target_locale locally
      # because we only allow editing of the original locale (see redirect_unless_editing_original_locale)
      # make sure we redirect to a locale the user has access to after translations are created or saved
      def target_locale(options = {})
        translated = @translated || @translatable
        override_locale = target_action.to_sym == :edit ? translated.original_locale : nil
        override_locale || options.delete(:locale) || (@translation.locale if @translation) || I18n.locale
      end
      
      # override mongo_translatable's target_controller locally
      # some kete translatables don't fall back under their own controller
      def target_controller(options = {})
        controller = options.delete(:controller)
        if controller.nil?
          key = options.delete(:translatable_params_name)
          if Kete.translatables[key] && Kete.translatables[key]['controller'].present?
            controller = Kete.translatables[key]['controller']
          else
            controller = key.pluralize
          end
        end
      end
    end

    # we only override specific extended field uses for translation
    # rather than overriding find
    ExtendedFieldsHelper.module_eval do
      def extended_field_example(extended_field)
        translated_example = extended_field.example_translation_for(I18n.locale) || extended_field.example
        h(translated_example)
      end
    end

    ApplicationHelper.module_eval do
      def display_label_for(field_or_choice)
        translated_label = field_or_choice.label_translation_for(I18n.locale) || field_or_choice.label
      end
    end

    unless Kete.extensions[:blocks]
      Kete.extensions[:blocks] = { :basket => Array.new, :user => Array.new, :system_setting => Array.new }
    end

    # models we extend
    require_blocks = ['basket', 'user', 'system_setting']
    require_path_stub = 'translatable_content/extensions/'

    require_blocks.each do |name|
      key = name.to_sym
      path_to_extension = require_path_stub + name

      extension_block = Proc.new { require path_to_extension }
      
      unless Kete.extensions[:blocks][key]
        Kete.extensions[:blocks][key] = Array.new
      end
      
      Kete.extensions[:blocks][key] << extension_block
    end
  end
end
