require 'mongo_translatable'
require 'kete_translatable_content'

config.to_prepare do

  # In development/production, we want to only setup stuff if IS_CONFIGURED is true
  # In test mode however, we always want to have it, since IS_CONFIGURED won't be true
  # at this stage, but it will be changed to true after Rails initializes.
  if (IS_CONFIGURED || Rails.env.test?) && kete_translatable_content_ready?

    Kete.translatables.each do |name, options|
      args = [:mongo_translate, *options['translatable_attributes']]
      args << { :redefine_find => options['redefine_find'] }
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
    I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '../config/locales/*.{rb,yml}') ]

    # override some controllers and helpers to be kete translatable aware
    exts = File.join(File.dirname(__FILE__), '../lib/kete_translatable_content/extensions/{controllers,helpers}/*')
    Dir[exts].each { |ext_path| require ext_path }

    # models we extend
    Kete.extensions[:blocks] ||= Hash.new
    Dir[ File.join(File.dirname(__FILE__), '../lib/kete_translatable_content/extensions/models/*') ].each do |ext_path|
      key = File.basename(ext_path, '.rb').to_sym
      Kete.extensions[:blocks][key] ||= Array.new
      Kete.extensions[:blocks][key] << Proc.new { require ext_path }
    end

  end

end
