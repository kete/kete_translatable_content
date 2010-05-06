require 'test_helper'

# test that models are translatable by making sure they respond
# to mongo_translatable instance methods
class ConfigureKeteContentTranslationTest < ActiveSupport::TestCase

  TRANSLATABLES.keys.each do |name|

    context "A #{name.humanize}" do

      setup do
        @record = name.camelize.constantize.new
      end

      should "respond to locale" do
        assert @record.respond_to?(:locale)
      end

      should "respond to translations" do
        assert @record.respond_to?(:translations)
      end

      should "respond to translations_locales" do
        assert @record.respond_to?(:translations_locales)
      end

      should "respond to translate" do
        assert @record.respond_to?(:translate)
      end

      should "respond to translation_for" do
        assert @record.respond_to?(:translation_for)
      end

      should "respond to available_in_these_locales" do
        assert @record.respond_to?(:available_in_these_locales)
      end

      should "respond to needed_in_these_locales" do
        assert @record.respond_to?(:needed_in_these_locales)
      end

    end

  end

end
