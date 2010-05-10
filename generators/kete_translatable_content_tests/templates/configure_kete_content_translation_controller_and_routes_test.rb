require 'test_helper'

# test that routes exist
# prepended with locale en which is added to all routes with a wrapper filter
class ConfigureKeteContentTranslationControllerAndRoutesTest < ActionController::TestCase

  context "The application's routing for baskets" do

    setup do
      @location = {
        :locale => "en",
        :urlified_name => "site",
        :controller => "translations",
        :basket_id => "1"
      }
    end

    should "have translations index" do
      assert_routing({ :path => "en/site/baskets/1/translations", :method => :get }, @location.merge(:action => "index"))
    end

    should "have translations new" do
      assert_routing({ :path => "en/site/baskets/1/translations/new", :method => :get }, @location.merge(:action => "new"))
    end

    should "have translations create" do
      assert_routing({ :path => "en/site/baskets/1/translations", :method => :post }, @location.merge(:action => "create"))
    end

    should "have translations show for a translation" do
      assert_routing({ :path => "en/site/baskets/1/translations/en", :method => :get }, @location.merge(:action => "show", :id => "en"))
    end

    should "have translations edit for a translation" do
      assert_routing({ :path => "en/site/baskets/1/translations/en/edit", :method => :get }, @location.merge(:action => "edit", :id => "en"))
    end

    should "have translations update for a translation" do
      assert_routing({ :path => "en/site/baskets/1/translations/en", :method => :put }, @location.merge(:action => "update", :id => "en"))
    end

    should "have translations destroy for a translation" do
      assert_routing({ :path => "en/site/baskets/1/translations/en", :method => :delete }, @location.merge(:action => "destroy", :id => "en"))
    end

  end

end
