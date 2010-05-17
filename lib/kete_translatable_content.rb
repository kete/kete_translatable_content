# Keep this file are bare as possible as it is used in migrations and routes
# and does not need to pull in mongo libs or adjust view paths. Such code
# should be done in ../rails/init.rb

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
