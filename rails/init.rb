require 'mongo_translatable'
require 'kete_translatable_content'
require 'kete_translatable_content/extensions/extended_content_translation'
require 'kete_translatable_content/extensions/translation_from_version'

config.to_prepare do

  # In development/production, we want to only setup stuff if IS_CONFIGURED is true
  # In test mode however, we always want to have it, since IS_CONFIGURED won't be true
  # at this stage, but it will be changed to true after Rails initializes.
  if (IS_CONFIGURED || Rails.env.test?) && kete_translatable_content_ready?

    Kete.translatables.each do |name, options|
      args = [:mongo_translate, *options['translatable_attributes']]
      args << { :redefine_find => options['redefine_find'],
        :through_version => options["through_version"]}
      
      class_name = name.camelize

      class_name.constantize.send(*args)

      if options["through_version"]
        class_name.constantize.send :include, TranslationFromVersion
        trans_class = class_name + "::Translation"
        trans_class.constantize.send :update_keys_if_necessary_with, [:version]
      end


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
    I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '../config/locales/*.{rb,yml}') ]

    # override some controllers and helpers to be kete translatable aware
    exts = File.join(File.dirname(__FILE__), '../lib/kete_translatable_content/extensions/{controllers,helpers}/*')
    # use Kernel.load here so that changes to the extensions are reloaded on each request in development
    Dir[exts].each { |ext_path| Kernel.load(ext_path) }

    # models we extend
    Kete.extensions[:blocks] ||= Hash.new
    Dir[ File.join(File.dirname(__FILE__), '../lib/kete_translatable_content/extensions/models/*') ].each do |ext_path|
      key = File.basename(ext_path, '.rb').to_sym
      Kete.extensions[:blocks][key] ||= Array.new
      Kete.extensions[:blocks][key] << Proc.new { Kernel.load(ext_path) }
    end

    # extend the Generic Muted Worker to have the expire_locale method
    MethodsForGenericMutedWorker.module_eval do
      def clear_locale_cache(options = { })
        locale_to_clear = options[:locale_to_clear]
        raise unless locale_to_clear
        
        # WARNING: this relies on the fact that Kete's current caching scheme is file system based
        # if an option for Memcache or other caching mechanism is used in the future
        # this will need to be updated with logic to figure out correct clearing mechanism
        file_path = "#{Rails.root}/tmp/cache/views/#{Kete.site_name}/#{locale_to_clear}"
        FileUtils.rm_r(file_path, :force => true) if File.exist?(file_path) && File.directory?(file_path)
      end
    end
  end
  if (IS_CONFIGURED || Rails.env.test?) && kete_translatable_content_ready?
    Kete.translatables.each do |name, options|
      class_name = name.camelize
      class_name.constantize.send :include, ExtendedContentTranslation
    end
  end
end
