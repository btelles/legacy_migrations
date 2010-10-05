require 'rubygems'
require 'rake/testtask'
require 'rake'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "legacy_migrations"
    gem.summary = "Rails plugin for transferring or updating data between two db structures."
    gem.description = "Rails plugin for transferring or updating data between two db structures."
    gem.email = "btelles@gmail.com"
    gem.homepage = "http://github.com/btelles/legacy_migrations"
    gem.authors = ["Bernie Telles"]
    gem.add_development_dependency "rspec", ">= 2.0.0.beta.22"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern= 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
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
