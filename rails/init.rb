require 'mongo_translatable'
require 'kete_translatable_content'
require 'kete'

config.to_prepare do
  kete_translatable_content_ready = true
  TRANSLATABLES.keys.each do |name|
    translatable = name.camelize.constantize.send(:new) rescue false
    kete_translatable_content_ready = translatable && translatable.respond_to?(:original_locale)
    break if kete_translatable_content_ready == false
  end

  # In development/production, we want to only setup stuff if IS_CONFIGURED is true
  # In test mode however, we always want to have it, since IS_CONFIGURED won't be true
  # at this stage, but it will be changed to true after Rails initializes.
  if (IS_CONFIGURED || Rails.env.test?) && kete_translatable_content_ready
    TRANSLATABLES.each do |name, options|
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
        translatable_controllers = TRANSLATABLES.keys.collect(&:pluralize)
        translatable_controllers.include?(params[:controller]) &&
          TRANSLATABLES[params[:controller].singularize]['views'].include?(params[:action])
      end
      helper_method :kete_translatable_content?

      def current_translatable_record
        key = params[:controller].singularize
        instance_variable_get('@' + key) || @item || @record || key.camelize.constantize.find(params[:id])
      end
      helper_method :current_translatable_record

      before_filter :reload_standard_baskets
      def reload_standard_baskets
        Rails.logger.info "[Kete Translatable Content]: Reloading Standard Baskets to be locale aware"
        @site_basket.reload
        @help_basket.reload
        @about_basket.reload
        @documentation_basket.reload
      end

      around_filter :redirect_unless_editing_original_locale
      def redirect_unless_editing_original_locale
        if kete_translatable_content? && params[:action] == 'edit'
          translated = current_translatable_record
          if I18n.locale.to_sym != translated.original_locale.to_sym
            flash[:error] = I18n.t('kete_translatable.only_edit_original_locale')
            redirect_to params.merge(:locale => translated.original_locale)
            return false
          end
        end

        yield
      end

      # override mongo_translatable's target_action locally
      def target_action(options = {})
        translated = @translated || @translatable
        # relies on first view defined in TRANSLATABLES for a key
        # being the redirect to action
        key = translated.class.name.tableize.singularize
        options.delete(:action) || TRANSLATABLES[key]['views'].first
      end

      # override mongo_translatable's target_locale locally
      # because we only allow editing of the original locale (see redirect_unless_editing_original_locale)
      # make sure we redirect to a locale the user has access to after translations are created or saved
      def target_locale(options = {})
        translated = @translated || @translatable
        override_locale = translated.original_locale if target_action.to_sym == :edit
        override_locale || options.delete(:action) || (@translation.locale if @translation) || I18n.locale
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
      Kete.extensions[:blocks] = { :basket => Array.new, :user => Array.new }
    end

    # TODO: DRY this up
    extension_block = Proc.new { require 'translatable_content/extensions/basket' }

    unless Kete.extensions[:blocks][:basket]
      Kete.extensions[:blocks][:basket] = Array.new
    end

    Kete.extensions[:blocks][:basket] << extension_block

    unless Kete.extensions[:blocks][:user]
      Kete.extensions[:blocks][:user] = Array.new
    end

    extension_block_user = Proc.new { require 'translatable_content/extensions/user' }

    Kete.extensions[:blocks][:user] << extension_block_user
  end
end
