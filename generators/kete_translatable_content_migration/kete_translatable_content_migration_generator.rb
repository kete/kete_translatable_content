class KeteTranslatableContentMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration:migration.rb', "db/migrate", {:assigns => kete_translatable_content_local_assigns,
        :migration_file_name => "add_kete_translatable_content_fields"
      }
    end
  end

  private
  def kete_translatable_content_local_assigns
    returning(assigns = {}) do
      assigns[:migration_action] = "add"
      assigns[:class_name] = "add_kete_translatable_content_fields"
      # TODO: see if this takes an array
      assigns[:table_name] = "baskets"
      assigns[:attributes] = [Rails::Generator::GeneratedAttribute.new("locale", "string"), Rails::Generator::GeneratedAttribute.new("original_locale", "string")]
    end
  end
end
