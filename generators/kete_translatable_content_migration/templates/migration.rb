require 'kete_translatable_content'

class AddKeteTranslatableContentFields < ActiveRecord::Migration
  def self.up
    TRANSLATABLES.keys.each do |name|
      table_name = name.tableize.to_sym
      add_column table_name, :locale, :string, :default => I18n.default_locale.to_s
      add_column table_name, :original_locale, :string, :default => I18n.default_locale.to_s
      if TRANSLATABLES[name]['additional_columns'] && TRANSLATABLES[name]['additional_columns'].any?
        TRANSLATABLES[name]['additional_columns'].each do |column|
          column_name = column.first.to_sym
          options = column.last
          args = [table_name, column_name, options['type'].to_sym]
          args << { :default => options['default'] } unless options['default'].nil?
          add_column *args
        end
      end
    end
  end

  def self.down
    TRANSLATABLES.keys.each do |name|
      table_name = name.tableize.to_sym
      remove_column table_name, :original_locale
      remove_column table_name, :locale
      if TRANSLATABLES[name]['additional_columns'] && TRANSLATABLES[name]['additional_columns'].any?
        TRANSLATABLES[name]['additional_columns'].each do |column|
          remove_column table_name, column.first.to_sym
        end
      end
    end
  end
end
