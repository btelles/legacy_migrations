require File.dirname(__FILE__) + '/squirrel/squirrel.rb'
class << ActiveRecord::Base
  include LegacyMigrations::Squirrel::Hook
end
 
if defined?(ActiveRecord::NamedScope::Scope)
  class ActiveRecord::NamedScope::Scope
    include LegacyMigrations::Squirrel::NamedScopeHook
  end
end
 
[ ActiveRecord::Associations::HasManyAssociation,
  ActiveRecord::Associations::HasAndBelongsToManyAssociation,
  ActiveRecord::Associations::HasManyThroughAssociation
].each do |association_class|
  association_class.send(:include, LegacyMigrations::Squirrel::Hook)
end
