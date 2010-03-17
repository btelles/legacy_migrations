require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper.rb'))

describe LegacyMigrations do
  require 'ruby-debug'
  describe 'transfer_from' do
    it "accepts a limit to the number of transfers to conduct" do
      3.times {|a| Person.create(:name => 'my first name') }

      transfer_from Person, :to => Animal, :limit => 2 do
        match_same_name_attributes
      end
      Animal.all.count.should == 2
    end
    it "validates by default" do
      Person.create(:name => 'aoeu 9')
      transfer_from Person, :to => Animal do
        match_same_name_attributes
      end
      Animal.all.count.should == 0
    end
    it "bypasses validation when the option is set" do
      Person.create(:name => 'aoeu 9')
      transfer_from Person, :to => Animal, :validate => false do
        match_same_name_attributes
      end
      Animal.all.count.should == 1
    end
    it "accepts a CSV file" do
      person = "a simple name,age\nalbert,123"
      person_csv = FasterCSV.parse(person, :headers => :first_row)
      transfer_from person_csv, :to => Animal, :source_type => :csv do
        from 'a simple name', :to => :name
      end
      Animal.first.name.should == 'albert'
    end
    it "limits a CSV file" do
      person = "a simple name,age\nalbert,123\nsmith,54"
      person_csv = FasterCSV.parse(person, :headers => :first_row)
      transfer_from person_csv, :to => Animal, :source_type => :csv, :limit => 1 do
        from 'a simple name', :to => :name
      end
      Animal.all.count.should == 1
    end
    it "rewinds an activerecord source" do
      Person.create(:name => 'aoeu')
      transfer_from Person, :to => Animal do
        from :name, :to => :name
      end
      transfer_from Person, :to => Animal do
        from :name, :to => :first_name
      end
      Animal.all.count.should == 2
      Animal.find_by_name('aoeu').should be_instance_of(Animal)
      Animal.find_by_first_name('aoeu').should be_instance_of(Animal)
    end
    it "rewinds a CSV source" do
      person = "name,age\nalbert,123\nsmith,54"
      person_csv = FasterCSV.parse(person, :headers => :first_row)
      transfer_from person_csv, :to => Animal, :source_type => :csv do
        from :name, :to => :name
      end
      transfer_from person_csv, :to => Animal, :source_type => :csv do
        from :name, :to => :first_name
      end
      Animal.all.count.should == 4
      Animal.find_by_name('albert').should be_instance_of(Animal)
      Animal.find_by_first_name('albert').should be_instance_of(Animal)
    end
    it "always returns a full status report" do
      Person.create(:name => 'aoeu')
      transfer_from Person, :to => Animal do
        from :name, :to => :name
      end
      a = update_from Person, :to => Animal do
        based_on do
          name == from.name
        end
        from :name, :to => :name
      end
      a.operations.size == 2
      a.operations[1].type == 'update'
    end
    it "retrieves a specified operation's results" do
      Person.create(:name => 'aoeu')
      transfer_from Person, :to => Animal do
        from :name, :to => :name
      end
      a = update_from Person, :to => Animal do
        based_on do
          name == from.name
        end
        from :name, :to => :name
      end
     update_op = a.operation_with(:destination => Animal, :type => 'update')
     update_op.should be_instance_of Operation
     update_op.source.should == Person
    end

    it "records all changes by default" do
      Person.create(:name => 'aoeu')
      a = transfer_from Person, :to => Animal do
        from :name, :to => :name
      end
      operation = a.operations.last
      operation.inserts.size.should == 1
      operation.inserts[0].should be_instance_of Animal
      operation.description.should == "Transfer of data from People to Animals resulted in 1 insert and 0 updates."
    end
  end
  describe 'update_from' do
    it "updates with simple column matching" do
      Person.create(:name => 'smithers', :age => 4)
      Animal.create(:name => 'smithers')
      update_from Person, :to => Animal do

        based_on do 
          name == from.name
        end

        from :name, :to => :name
        from :age, :to => :age
      end
      Animal.find_by_name('smithers').age.should == 4
      Animal.all.count.should == 1
    end
    it "inserts if a matching record does not exist" do
      Person.create(:name => 'smithers', :age => 4)
      Person.create(:name => 'simpson', :age => 8)
      Animal.create(:name => 'simpson')
      update_from Person, :to => Animal do

        based_on do
          name == from.name
        end

        from :name, :to => :name
        from :age, :to => :age
      end
      Animal.find_by_name('smithers').age.should == 4
      Animal.find_by_name('simpson').age.should == 8
      Animal.all.count.should == 2
    end
  end
end

