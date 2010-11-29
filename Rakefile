require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "kete_translatable_content"
    gem.summary = %Q{An add-on to the Kete application to provide content translations.}
    gem.description = %Q{Kete Translatable Content is a gem that is an add-on for Kete web applications that takes advantage of the mongo_translatable gem functionality. As you would expect, you use it to add the ability to translate content in your Kete web site.}
    gem.email = "walter@katipo.co.nz"
    gem.homepage = "http://github.com/kete/kete_translatable_content"
    gem.authors = ["Walter McGinnis", "Kieran Pilkington", "Breccan McLeod-Lundy"]
    gem.add_development_dependency "mongo_translatable", ">= 0"
    gem.files.exclude 'test/kete_test_app'
    gem.test_files.exclude 'test/kete_test_app'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  puts "This gem needs to be tested in the context of a full kete app. See README for details about how to generate and run tests."
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "kete_translatable_content #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
