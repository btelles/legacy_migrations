require 'rubygems'
require 'rake/testtask'
require 'rake'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "legacy_migrations"
    gem.summary = "Rails plugin for transferring or updating data between two db structures."
    gem.description = "Rails plugin for transferring or updating data between two db structures."
    gem.email = "bernardo.telles@dms.myflorida.com"
    gem.homepage = "http://github.com/btelles/legacy_migrations"
    gem.authors = ["Bernie Telles"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "legacy_migrations #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
desc 'Default: run unit tests.'
task :default => :test

desc 'Test the legacy_migrations plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end
