class Person < ActiveRecord::Base
  #name
  #not_name
  #age
end

class Animal < ActiveRecord::Base
  validates_format_of :name, :with => /^(\D)*$/, :allow_nil => true
  #name
  #not_name
  #first_name
  #age
end
require 'legacy_migrations'
