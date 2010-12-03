# -*- coding: utf-8 -*-
require 'test_helper'
require 'mongo_test_helper'

class MongodbTranslatableTest < ActiveSupport::TestCase
  context "A translation" do
    setup do
      I18n.locale = I18n.default_locale

      @topic_type = Factory.create(:topic_type)

      topic_type_hash = Hash.new
      topic_type_hash[:name] = @topic_type.attributes['name']
      topic_type_hash[:locale] = :fr
      topic_type_hash[@topic_type.class.as_foreign_key_sym] = @topic_type.id
      @translation = @topic_type.class::Translation.create(topic_type_hash)
    end

    should "have a locale" do
      if assert(@translation.respond_to?(:locale))
        assert @translation.locale
      end
    end

    should "have a translated object's translated attributes" do
      assert @translation.attributes[TopicType.translatable_attributes.first]
    end

    should "be accessable from its topic_type" do
      if assert(@topic_type.respond_to?(:translations))
        assert @topic_type.translation_for(I18n.locale)
      end
    end

    should "be able to retrieve just the translated attribute" do
      if assert(@topic_type.respond_to?(:translations) && @topic_type.respond_to?(:name_translation_for))
        assert @topic_type.name_translation_for(I18n.locale)
      end
    end

    should "be able to retrieve its topic_type from the topic_type's persistence" do
      assert @translation.translatable
    end
  end

  context "When there is an TopicType needing translating" do
    setup do
      @topic_type = Factory.create(:topic_type, { :name => LOCALE_LABELS[:en] })
    end

    #Create id 1
    should "create translation" do
      translate_topic_type_for_locales(@topic_type, :zh)
      assert @topic_type.translations.count == 1
    end

    should "not create translation if no translated text submitted" do
      # arabic
      I18n.locale = :ar
      @topic_type.translate
      assert @topic_type.translations.count == 0
    end

    should "not create translation if topic_type's original_locale is same as translation locale" do
      I18n.locale = :en
      @topic_type.translate(:name => LOCALE_LABELS[:en])
      assert @topic_type.translations.count == 0
    end

    should "create translation and it should reflect current locale" do
      # french
      translate_topic_type_for_locales(@topic_type, :fr)
      assert @topic_type.translation_for(:fr)
    end

    should "find topic_type with the proper translation for current locale" do
      translate_topic_type_for_locales(@topic_type, :fi)

      I18n.locale = :fi
      # reloading topic_type should detect current locale and pass back translated version of object
      @topic_type = TopicType.find(@topic_type.id)

      assert_equal @topic_type.name, LOCALE_LABELS[:fi]
    end

    should "find topic_type with the proper translation for current locale and fallback to original's description for translatable attribute that hasn't been translated" do
      translate_topic_type_for_locales(@topic_type, :fi)

      original_description = @topic_type.description

      I18n.locale = :fi
      # reloading topic_type should detect current locale and pass back translated version of object
      @topic_type = TopicType.find(@topic_type.id)

      assert_equal @topic_type.name, LOCALE_LABELS[:fi]
      assert_equal original_description, @topic_type.description
    end

    should "find topic_type with the proper translation for current locale when there is more than one translation" do
      # add a couple translations
      translate_topic_type_for_locales(@topic_type, [:fi, :fr])

      # then back to finnish
      I18n.locale = :fi

      # reloading topic_type should detect current locale and pass back translated version of object
      @topic_type = TopicType.find(@topic_type.id)

      assert_equal @topic_type.name, LOCALE_LABELS[:fi]
    end

    # test dynamic finder
    should "find topic_type with the proper translation for current locale when there is more than one translation and finding using dynamic finder" do
      @topic_type = Factory.create(:topic_type, {:description => "a description"})

      # add a couple translations
      translate_topic_type_for_locales(@topic_type, [:fi, :fr])

      # then back to finnish
      I18n.locale = :fi

      # reloading topic_type should detect current locale and pass back translated version of object
      @topic_type = TopicType.find_by_description(@topic_type.description)

      assert_equal @topic_type.name, LOCALE_LABELS[:fi]
    end

    should "after creating translations, if the topic_type is destroyed, the translations are destroyed" do
      # add a couple translations
      translate_topic_type_for_locales(@topic_type, [:fi, :fr])

      translations_ids = @topic_type.translations.collect { |translation| translation.id }

      @topic_type.destroy

      remaining_translations = TopicType::Translation.find(translations_ids)

      assert_equal 0, remaining_translations.size
    end

    should "when the topic_type is destroyed, when it has no translations, it should succeed in being destroyed" do
      assert_equal 0, @topic_type.translations.size
      assert @topic_type.destroy
    end

    teardown do
      I18n.locale = @original_locale
      @topic_type.destroy if @topic_type
    end
  end

  context "When there are many topic_types being translated" do
    setup do
      # TODO: pull out this locale, not sure why before_save filter is not being called
      @original_locale = I18n.locale
    end

    should "find topic_types with the proper translation for current locale" do
      ids = many_setup

      # reloading topic_type should detect current locale and pass back translated version of object
      @topic_types = TopicType.find(ids)

      many_tests
    end

    should "find topic_types with the proper translation for current locale using dynamic finder" do
      description = "a description"
      many_setup({:description => description})

      # reloading topic_type should detect current locale and pass back translated version of object
      @topic_types = TopicType.find_all_by_description(description)

      many_tests(:fi => 10)
    end

    teardown do
      I18n.locale = @original_locale
      @topic_type.destroy if @topic_type
    end
  end

  context "translations for an topic_type" do
    setup do
      I18n.locale = I18n.default_locale
      @topic_type = Factory.create(:topic_type)
      @translation_keys = LOCALE_LABELS.keys - [:en]
      translate_topic_type_for_locales(@topic_type, @translation_keys)
    end

    should "be retrievable from translations method" do
      assert_equal @translation_keys.size, @topic_type.translations.size
    end

    should "hae just locales be retrievable from translations_locales method" do
      # these should be partial objects and not have any descriptions for other attributes
      locale_keys = @topic_type.translations_locales.collect { |translation| translation.locale.to_sym if translation.name.nil? }.compact

      assert_equal 0, (@translation_keys - locale_keys).size
    end

    should "have translation locales plus original local be retrievable as available_in_these_locales" do
      locale_keys = @topic_type.available_in_these_locales.collect { |locale| locale.to_sym }

      assert_equal 0, ( ([:en] + @translation_keys) - locale_keys ).size
    end

    should "have needed_in_these_locales method that returns locales that haven't been translated yet" do
      TopicType::Translation.first(:topic_type_id => @topic_type.id, :locale => "zh").destroy
      assert_equal [:zh], @topic_type.needed_in_these_locales.collect { |locale| locale.to_sym }
    end

    teardown do
      I18n.locale = @original_locale
      @topic_type.destroy if @topic_type
    end
  end



  private

  # see many_tests for what it expects
  def many_setup(topic_type_spec = nil)
    ids = Array.new
    5.times do
      I18n.locale = @original_locale
      topic_type = topic_type_spec ? Factory.create(:topic_type, topic_type_spec) : Factory.create(:topic_type)
      translate_topic_type_for_locales(topic_type, [:ar, :fr])
      ids << topic_type.id
    end

    5.times do
      I18n.locale = @original_locale
      topic_type = topic_type_spec ? Factory.create(:topic_type, topic_type_spec) : Factory.create(:topic_type)
      translate_topic_type_for_locales(topic_type, [:zh, :fi])
      ids << topic_type.id
    end

    # excluding these from ids searched
    5.times do
      I18n.locale = @original_locale
      topic_type = topic_type_spec ? Factory.create(:topic_type, topic_type_spec) : Factory.create(:topic_type)
      translate_topic_type_for_locales(topic_type, [:fr, :fi])
    end

    I18n.locale = :fi
    ids
  end

  # expect 5 en, 5 finnish, and none in french, chinese, or arabic
  def many_tests(passed_amounts = { })
    results_number_for = { :fi => 5, :en => 5, :fr => 0, :ar => 0, :zh => 0}
    results_number_for.merge!(passed_amounts)

    assert_equal results_number_for[:fi], @topic_types.select { |i| i.locale.to_sym == :fi }.size
    assert_equal results_number_for[:en], @topic_types.select { |i| i.locale.to_sym == :en }.size
    assert_equal results_number_for[:fr], @topic_types.select { |i| i.locale.to_sym == :fr }.size
    assert_equal results_number_for[:ar], @topic_types.select { |i| i.locale.to_sym == :ar }.size
    assert_equal results_number_for[:zh], @topic_types.select { |i| i.locale.to_sym == :zh }.size
  end
end
