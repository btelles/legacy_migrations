#if Rails::VERSION::STRING =~ /^3\..*/
#  require 'rspec'
#  require 'rspec-rails'
#  require 'ruby-debug'
#end
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))
$TESTING=true
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))


plugin_spec_dir = File.dirname(__FILE__)

load(File.join(plugin_spec_dir, "db", "schema.rb"))
require 'fastercsv'
require 'models'

  # == Fixtures
  #
if Rails::VERSION::STRING =~ /^3\..*/
  Rspec.configure do |config|
  end
else
  Spec::Runner.configure do |config|

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  end
end
