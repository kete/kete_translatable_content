require 'kete_translatable_content'

class AddKeteTranslatableContentFields < ActiveRecord::Migration
  def self.up
    TRANSLATABLES.keys.each do |name|
      add_column name.tableize.to_sym, :locale, :string, :default => I18n.default_locale.to_s
      add_column name.tableize.to_sym, :original_locale, :string, :default => I18n.default_locale.to_s
    end
  end

  def self.down
    TRANSLATABLES.keys.each do |name|
      remove_column name.tableize.to_sym, :original_locale
      remove_column name.tableize.to_sym, :locale
    end
  end
end
