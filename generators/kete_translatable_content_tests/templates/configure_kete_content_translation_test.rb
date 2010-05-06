require 'test_helper'

require 'mongo_translatable'
require 'kete_translatable_content'
Basket.send(:mongo_translate, :name)

class ConfigureKeteContentTranslationTest < ActiveSupport::TestCase
  # test that models are translatable by making sure they respond
  # to mongo_translatable instance methods
  context "A basket" do
    setup do
      @basket = Basket.first
    end
    should "respond to locale" do
      assert @basket.respond_to?(:locale)
    end

    should "respond to translations" do
      assert @basket.respond_to?(:translations)
    end

    should "respond to translations_locales" do
      assert @basket.respond_to?(:translations_locales)
    end

    should "respond to translate" do
      assert @basket.respond_to?(:translate)
    end

    should "respond to translation_for" do
      assert @basket.respond_to?(:translation_for)
    end

    should "respond to available_in_these_locales" do
      assert @basket.respond_to?(:available_in_these_locales)
    end

    should "respond to needed_in_these_locales" do
      assert @basket.respond_to?(:needed_in_these_locales)
    end
  end
end
