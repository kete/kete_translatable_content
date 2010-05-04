require 'kete_translatable_content'

class AddKeteTranslatableContentFields < ActiveRecord::Migration
  def self.up
    TRANSLATABLES.each do |name, spec_hash|
      add_column name.camelize.constantize.table_name.to_sym, :locale, :string, :default => I18n.default_locale.to_s
      add_column name.camelize.constantize.table_name.to_sym, :original_locale, :string, :default => I18n.default_locale.to_s
    end
  end

  def self.down
    TRANSLATABLES.each do |name, spec_hash|
      remove_column name.camelize.constantize.table_name.to_sym, :original_locale
      remove_column name.camelize.constantize.table_name.to_sym, :locale
    end
  end
end
