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

def kete_translatable_content_ready?
  kete_translatable_content_ready = true
  Kete.translatables.keys.each do |name|
    translatable = name.camelize.constantize.send(:new) rescue false
    kete_translatable_content_ready = translatable && translatable.respond_to?(:original_locale)
    break if kete_translatable_content_ready == false
  end
  kete_translatable_content_ready
end
