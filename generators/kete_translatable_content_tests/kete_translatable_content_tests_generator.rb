class KeteTranslatableContentTestsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.template 'configure_kete_content_translation_controller_and_routes_test.rb',
                  File.join('test/functional',
                            'configure_kete_content_translation_controller_and_routes_test.rb')

      m.template 'kete_translatable_content_helper_test.rb',
                  File.join('test/unit/helpers',
                            "kete_translatable_content_helper_test.rb")

      m.template 'configure_kete_content_translation_test.rb',
                  File.join('test/unit',
                            'configure_kete_content_translation_test.rb')

      m.template 'kete_translatable_content_migration_test.rb',
                  File.join('test/unit',
                            'kete_translatable_content_migration_test.rb')

      m.template 'kete_translations_test.rb',
                  File.join('test/integration',
                            'kete_translations_test.rb')
    end
  end
end
