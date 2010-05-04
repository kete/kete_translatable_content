class KeteTranslatableContentMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', { :migration_file_name => "add_kete_translatable_content_fields" }
    end
  end
end
