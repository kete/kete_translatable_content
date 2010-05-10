require 'test_helper'

# test that the translations for each model are available (so when
# new translatable fields are added, it doesn't have missing strings)
class KeteTranslatableContentTranslationsTest < ActiveSupport::TestCase

  TRANSLATABLES.each do |name, attributes|

    context "The #{name.humanize} translatable" do

      attributes['translatable_attributes'].each do |attr|

        should "have a translation for #{attr}" do
          assert I18n.t("#{name.pluralize}.form.#{attr}") !~ /translation missing/
        end

      end

    end

  end

end
