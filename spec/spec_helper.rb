require 'rspec'
require 'rspec-rails'
require 'ruby-debug'

require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))
$TESTING=true
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

 
plugin_spec_dir = File.dirname(__FILE__)

load(File.join(plugin_spec_dir, "db", "schema.rb"))

  # == Fixtures
  #
Rspec.configure do |config|
end


