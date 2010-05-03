require 'test_helper'
class ConfigureKeteContentTranslationControllerAndRoutesTest < ActionController::TestCase
  # test that routes exist
  # prepended with locale en which is added to all routes with a wrapper filter
  context "The application's routing for baskets" do 
    should "have translations index" do 
      assert_routing({ :path => "en/site/baskets/1/translations", :method => :get }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "index" })
    end
    should "have translations new" do 
      assert_routing({ :path => "en/site/baskets/1/translations/new", :method => :get }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "new" })
    end
    should "have translations create" do 
      assert_routing({ :path => "en/site/baskets/1/translations", :method => :post }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "create" })
    end
    should "have translations show for a translation" do 
      assert_routing({ :path => "en/site/baskets/1/translations/en", :method => :get }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "show", :id => "en"})
    end
    should "have translations edit for a translation" do 
      assert_routing({ :path => "en/site/baskets/1/translations/en/edit", :method => :get }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "edit", :id => "en"})
    end
    should "have translations update for a translation" do 
      assert_routing({ :path => "en/site/baskets/1/translations/en", :method => :put }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "update", :id => "en"})
    end
    should "have translations destroy for a translation" do 
      assert_routing({ :path => "en/site/baskets/1/translations/en", :method => :delete }, { :locale => "en", :urlified_name => "site", :controller => "translations", :basket_id => "1", :action => "destroy", :id => "en"})
    end
  end
end
