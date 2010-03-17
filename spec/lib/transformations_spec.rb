require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper.rb'))

describe "transformations" do
  describe 'from' do
    it "transfers attributes, given the two names" do
      Person.create(:name => 'my first name')
      transfer_from Person, :to => Animal do
        from :name, :to => :first_name
      end
      Animal.first.first_name.should == 'my first name'
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
    it 'allows user to specify an :if function' do
      def function_returning_false(from_record); false; end
      Person.create(:name => 'my first name')
      transfer_from Person, :to => Animal do
        from :name, :to => :first_name, :if => :function_returning_false
        from :name, :to => :name
      end
      Animal.first.first_name.should == nil
      Animal.first.name.should == 'my first name'
    end
    it "allows user to use 'from_record' instead of column" do
      Person.create(:name => 'my first name')
      transfer_from Person, :to => Animal do
        from :from_record, :to => :first_name do |from_record|
          from_record.name.upcase
        end
      end
      Animal.first.first_name.should == 'MY FIRST NAME'
    end
    describe "match_same_name_attributes" do
      it "transfers same-name attributes" do
        Person.create(:name => 'same name')
        transfer_from Person, :to => Animal do
          match_same_name_attributes
        end
        Animal.first.name.should == 'same name'
      end
      it "lets the user select all attributes EXCEPT a few for transfer" do
        Person.create(:name => 'choose_me', :not_name => 'not_this_one')
        transfer_from Person, :to => Animal do
          match_same_name_attributes :except => [:name]
        end
        animal = Animal.first
        animal.name.should == 'choose_me'
        animal.not_name.should == nil
      end
      it "lets the user select only some attributes for transfer" do
        Person.create(:name => 'only', :not_name => 'not_this')
        transfer_from Person, :to => Animal do
          match_same_name_attributes :only => [:name]
        end
        animal = Animal.first
        animal.name.should == 'only'
        animal.not_name.should == nil
      end
    end
  end
end
