require 'kete_translatable_content'
class ActiveRecord::Migration

  def self.add_additional_columns_for(name, table_name)
    if Kete.translatables[name]['additional_columns'] && Kete.translatables[name]['additional_columns'].any?
      Kete.translatables[name]['additional_columns'].each do |column|
        column_name = column.first.to_sym
        options = column.last
        args = [table_name, column_name, options['type'].to_sym]
        args << { :default => options['default'] } unless options['default'].nil?
        add_column *args

        if through_version?(name)
          args[0] = resolve_to_table(name, :without_versions => true)
          add_column *args
        end
      end
    end
  end

  def self.remove_additional_columns_for(name, table_name)
    if Kete.translatables[name]['additional_columns'] && Kete.translatables[name]['additional_columns'].any?
      Kete.translatables[name]['additional_columns'].each do |column|
        remove_column(table_name, column.first.to_sym) rescue nil

        if through_version?(name)
          remove_column(resolve_to_table(name, :without_versions => true), column.first.to_sym) rescue nil
        end
      end
    end
  end

  def self.add_locale_columns_to(table_name)
    add_column table_name, :locale, :string, :default => I18n.default_locale.to_s
    add_column table_name, :original_locale, :string, :default => I18n.default_locale.to_s
  end

  def self.remove_locale_columns_to(table_name)
    remove_column(table_name, :locale) rescue nil
    remove_column(table_name, :original_locale) rescue nil
  end

  def self.through_version?(name)
    Kete.translatables[name]['through_version'].present? ? Kete.translatables[name]['through_version'] : false
  end

  def self.resolve_to_table(name, options = { })
    include_versions = options[:without_versions].present? ? options[:without_versions] : false 

    table_name = through_version?(name) && include_versions ? name + '_versions' : name.tableize

    table_name = table_name.to_sym
  end
end

class AddKeteTranslatableContentFields < ActiveRecord::Migration
  def self.up
    Kete.translatables.keys.each do |name|
      debugger
      
      table_name = resolve_to_table(name)

      add_locale_columns_to(table_name)

      add_locale_columns_to(resolve_to_table(name, :without_versions => true)) if through_version?(name)

      add_additional_columns_for(name, table_name)
    end
  end

  def self.down
    Kete.translatables.keys.each do |name|
      table_name = resolve_to_table(name)

      remove_locale_columns_to(table_name)

      remove_locale_columns_to(resolve_to_table(name, :without_versions => true)) if through_version?(name)

      remove_additional_columns_for(name, table_name)
    end
  end
end

