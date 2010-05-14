require 'test_helper.rb'
require 'rails_generator'
require 'rails_generator/scripts/generate'

class MigrationGeneratorTest < ActiveSupport::TestCase

  context "Calling script/generate kete_translatable_content_migration" do

    setup do
      FileUtils.mkdir_p(fake_rails_root)
      @original_files = file_list
    end

    should "generate correct file with kete's translatable models" do
      Rails::Generator::Scripts::Generate.new.run(["kete_translatable_content_migration"],
                                                  :destination => fake_rails_root)
      new_file = (file_list - @original_files).first
      assert_match /add_kete_translatable_content_fields/, new_file
      assert_match /require \'kete_translatable_content\'/, File.read(new_file)
      assert_match /Kete.translatables.keys.each/, File.read(new_file)
    end

    teardown do
      FileUtils.rm_r(fake_rails_root)
    end

  end

  private

  def fake_rails_root
    File.join(File.dirname(__FILE__), 'rails_root')
  end

  def file_list
    Dir.glob(File.join(fake_rails_root, "db", "migrate", "*"))
  end

end
