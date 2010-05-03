# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/integration_test_helper'

class KeteTranslationsTest < ActionController::IntegrationTest
  context "A translatable basket" do
    include Webrat::HaveTagMatcher
    setup do
      @basket = Factory.create(:basket)
    end

    should "have links to locales needing translation on its show page" do
      visit "/en/baskets/1/edit"
      assert_contain "Needs translating to"
      assert_have_tag "a", :href => "/en/baskets/1/translations/new?to_locale=zh", :content => "中文"
    end

    context "that has been previously translated" do

      setup do
        translate_basket_for_locales(@basket, [:zh])
      end

      should "have locales that have been translated on its show page" do
        visit "/en/baskets/1/edit"
        assert_have_tag "li", :content => "Français"
        assert_have_tag "a", :href => "/zh/baskets/1/edit", :content => "中文"
      end

    end
  end
end
