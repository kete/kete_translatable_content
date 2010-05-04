require 'test_helper'

class KeteTranslatableContentHelperTest < ActionView::TestCase
  # test that ApplicationHelper includes the mongo_translatable's gem
  # helper is included
  context "ApplicationHelper" do
    should "include TranslatablesHelper#needed_in_locales_for" do 
      assert defined?(:needed_in_locales_for)
    end
    should "include KeteTranslatableContentHelper#kete_translatable_content?" do 
      assert defined?(:kete_translatable_content?)
    end
  end
end
