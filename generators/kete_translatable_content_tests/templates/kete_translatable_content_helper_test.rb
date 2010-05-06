require 'test_helper'

# test that ApplicationHelper includes the mongo_translatable's gem
# helper is included
class KeteTranslatableContentHelperTest < ActionView::TestCase

  context "The ActionController Helpers" do

    should "include TranslatablesHelper#needed_in_locales_for" do
      assert ApplicationController.helpers.methods.include?('needed_in_locales_for')
    end

    should "include KeteTranslatableContentHelper#kete_translatable_content?" do
      assert ApplicationController.helpers.methods.include?('kete_translatable_content?')
    end

  end

end
