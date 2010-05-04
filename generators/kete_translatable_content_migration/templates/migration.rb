require 'kete_translatable_content'

class AddKeteTranslatableContentFields < ActiveRecord::Migration
  def self.up
    TRANSLATABLES.each do |name, spec_hash|
      add_column name.camelize.constantize.table_name.to_sym, :locale, :string
      add_column name.camelize.constantize.table_name.to_sym, :original_locale, :string
    end
  end

  def self.down
    TRANSLATABLES.each do |name, spec_hash|
      remove_column name.camelize.constantize.table_name.to_sym, :original_locale
      remove_column name.camelize.constantize.table_name.to_sym, :locale
    end
  end
end
