# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/integration_test_helper'

def translate_for_locales(record, *locales)
  locales.each do |locale|
    visit "/en/site/#{record.class.name.pluralize.downcase}/#{record.id}/translations/new?to_locale=#{locale}"
    click_button 'Create'
    assert_contain 'Translation was successfully created.'
  end
end

class KeteTranslationsTest < ActionController::IntegrationTest

  context "A translatable basket" do

    include Webrat::HaveTagMatcher

    setup do
      add_admin_as_super_user
      login_as('admin')

      # create_new_basket is a method in Kete's integration helpers to create
      # the basket, and remove it when tests are run (so each test has a clean
      # environment)
      @basket = create_new_basket :name => 'Translatable Basket'
    end

    should "have links to locales needing translation on its show page" do
      visit "/en/#{@basket.urlified_name}/baskets/edit/#{@basket.id}"
      assert_contain "Needs translating to"
      assert_have_tag "a", :href => "/en/#{@basket.urlified_name}/baskets/#{@basket.id}/translations/new?to_locale=zh", :content => "中文"
    end

    context "that has been previously translated" do

      setup do
        translate_for_locales(@basket, :zh)
      end

      should "have locales that have been translated on its show page" do
        visit "/en/#{@basket.urlified_name}/baskets/edit/#{@basket.id}"
        assert_have_tag "li", :content => "Français"
        assert_have_tag "a", :href => "/zh/#{@basket.urlified_name}/baskets/edit/#{@basket.id}", :content => "中文"
      end

    end

  end

end
