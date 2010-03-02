require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper.rb'))

class Person < ActiveRecord::Base
  #name
end

class Animal < ActiveRecord::Base
  #name
  #first_name
end
require 'legacy_migrations'

describe LegacyMigrations do
  require 'ruby-debug'
  describe 'transfer_from' do
    it "transfers attributes, given the two names" do
      Person.create(:name => 'my first name')
      transfer_from Person, :to => Animal do
        from :name, :to => :first_name
      end
      Animal.first.first_name.should == 'my first name'
    end
    it "transfers same-name attributes" do
      Person.create(:name => 'same name')
      transfer_from Person, :to => Animal do
        match_same_name_attributes
      end
      Animal.first.name.should == 'same name'
    end
    it "transfers attributes, given a block" do
      Person.create(:name => 'my first name')
      transfer_from Person, :to => Animal do
        from :name, :to => :first_name do |name|
          name.upcase
        end
      end
      Animal.first.first_name.should == 'MY FIRST NAME'

    end

  end
end

