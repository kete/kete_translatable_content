# Keep this file are bare as possible as it is used in migrations and routes
# and does not need to pull in mongo libs or adjust view paths. Such code
# should be done in ../rails/init.rb

require 'kete_translatable_content/kete'

Kete.define_reader_method_as('translatables',
                             YAML.load(IO.read(File.join(File.dirname(__FILE__), '../config/translatables.yml'))))

Kete.define_reader_method_as('translatable_system_settings', ['Pretty Site Name',
                                                              'Flagging Tags',
                                                              'Download Warning',
                                                              'Blank Title',
                                                              'Pending Flag',
                                                              'Rejected Flag',
                                                              'Blank Flag',
                                                              'Reviewed Flag',
                                                              'No Public Version Title',
                                                              'No Public Version Description',
                                                              'Government Website',
                                                              'Default Page Keywords',
                                                              'Default Page Description',
                                                              'Additional Credits HTML',
                                                              'Restricted Flag'
                                                             ])

Kete.define_reader_method_as('translatable_configurable_settings',
                             ['additional_footer_content'])

Kete.define_reader_method_as('translatable_tiny_mce_options', {
  :width => '390',
  :theme => 'advanced',
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_buttons1 => %w{ bold italic underline strikethrough separator justifyleft justifycenter justifyright justifyfull separator indent outdent separator bullist numlist separator link unlink image },
  :theme_advanced_buttons2 => %w{ formatselect fontselect fontsizeselect separator forecolor backcolor separator undo redo },
  :theme_advanced_buttons3 => %w{ tablecontrols separator fullscreen separator code },
  :theme_advanced_resizing => true,
  :theme_advanced_resize_horizontal => false,
  :convert_urls => false,
  :content_css => "/stylesheets/base.css",
  :plugins => %w{ table fullscreen paste }
})

def kete_translatable_content_ready?
  kete_translatable_content_ready = true
  Kete.translatables.keys.each do |name|
    translatable = name.camelize.constantize.send(:new) rescue false
    kete_translatable_content_ready = translatable && translatable.respond_to?(:original_locale)
    break if kete_translatable_content_ready == false
  end
  kete_translatable_content_ready
end
