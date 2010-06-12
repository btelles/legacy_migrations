require 'legacy_migrations/transformations'
require 'legacy_migrations/future_storage'
require 'legacy_migrations/squirrel'
module LegacyMigrations

  # Define a source and destination table to transfer data
  #
  # ==== Options
  #
  # * <tt>:to</tt> - (Required) Class of the destination table
  # * <tt>:limit</tt> - Set a limit to the number of rows to transfer.
  #   This is useful when you're trying to find faulty data in the source
  #   table, and don't want to run the entire dataset.
  # * <tt>:validate</tt> - Default = true. Use ActiveRecord validations
  #   when saving the destination rows.
  # * <tt>:source_type</tt> - Default = :active_record. Sets the source
  #   destination type.
  #   Options:
  #   _:active\_record_: Assumes the From option is a class that inherits
  #   from ActiveRecord::Base, then iterates through each record of From
  #   table by using *From*.all.each...
  #   _:other_: Assumes the From option is an iterable 'collection' whose 
  #   elements/items can respond to all source methods speficied in the given block.
  # * <tt>:store_as</tt> - Stores the generated destination record as a key
  #   that is retrievable in other transformations. Note that for this to work, the 
  #   source object must respond to the method <tt>id</tt> which returns
  #   a value that is unique for all rows within the table (usually 
  #   this is just a primary key).
  #
  #   _Example_
  #   <tt>
  #   transfer_from Mammal, :to => Species, :store_as => 'new_animal' do
  #     match_same_name_attributes
  #   end
  #
  #   transfer_from Person, :to => Animal do
  #     stored 'new_animal', :to => :species
  #   end
  #   </tt>
  #   
  def transfer_from(from_table, *args, &block)

    configure_transfer(from_table, *args) { yield }
    @current_operation = StatusReport.instance.add_operation :source => @from_table,
                                        :destination => @to_table,
                                        :source_type => args.extract_options![:source_type] || :active_record,
                                        :type => 'transfer'


    source_iterator(@limit, @type).each do |from_record|
      new_destination_record(from_record)
    end
    @status_report
  end

  # Define a source and destination table with which to update data
  #
  # This method accepts all of the same options as <tt>transfer_from</tt>.
  #
  # In addition, you'll need to use a series of columns that match data
  # from the source to the destination. For example, if your source  and 
  # destination data have a social security number, then you'd use the
  # social security number to match records from the two rows. The following
  # is how you would do that.
  #
  # <tt>
  # update_from SourceTable, :to => DestinationTable do 
  #   based_on do
  #     ssn == from.social_security_number
  #   end
  # end
  # </tt>
  #
  # Note that when using the 'based_on' method, the left-hannd item always
  # corresponds to a column method on the destination table.
  # 
  # The methods available in the based_on block correspond to the well-known
  # squirrel plugin's syntax. Here's a quick review of the possible operators:
  #
  # Handles comparisons in the query. This class is analagous to the columns in the database.
  # When comparing the Condition to a value, the operators are used as follows:
  # * ==, === : Straight-up Equals. Can also be used as the "IN" operator if the operand is an Array.
  # Additionally, when the oprand is +nil+, the comparison is correctly generates as "IS NULL"."
  # * =~ : The LIKE and REGEXP operators. If the operand is a String, it will generate a LIKE
  # comparison. If it is a Regexp, the REGEXP operator will be used. NOTE: MySQL regular expressions
  # are NOT the same as Ruby regular expressions. Also NOTE: No wildcards are inserted into the LIKE
  # comparison, so you may add them where you wish.
  # * <=> : Performs a BETWEEN comparison, as long as the operand responds to both #first and #last,
  # which both Ranges and Arrays do.
  # * > : A simple greater-than comparison.
  # * >= : Greater-than or equal-to.
  # * < : A simple less-than comparison.
  # * <= : Less-than or equal-to.
  # * contains? : Like =~, except automatically surrounds the operand in %s, which =~ does not do.
  # * nil? : Works exactly like "column == nil", but in a nicer syntax, which is what Squirrel is all about.
  #
  # ==== Options
  #
  # 
  def update_from(from_table, *args, &block)

    configure_transfer(from_table, *args) { yield }

    @current_operation = StatusReport.instance.add_operation :source => @from_table,
                                        :destination => @to_table,
                                        :source_type => args.extract_options![:source_type] || :active_record,
                                        :type => 'update'
    source_iterator(@limit, @type).each do |from_record|
      matching_records = @conditions.call(from_record)

      unless matching_records.empty?
        matching_records.each do |to_record|
          @columns.each do |to, from|
            to_record[to]= from.call(from_record)
          end

          if @options[:validate]
            report_validation_errors(to_record, from_record, 'update')
          else
            to_record.save(false)
            @current_operation.record_update(to_record)
          end
          store_as(to_record, from_record)
        end
      else
        new_destination_record(from_record)
      end
    end
    @status_report
  end

  private

  def configure_transfer(from_table, *args, &block)
    @columns = {}

    @options = {:validate => true}.merge(args.extract_options!)


    @from_table = from_table
    @to_table = @options[:to]

    add_storage_attribute if @options[:store_as].present?

    @status_report = StatusReport.instance

    yield

    @limit = @options[:limit] ? {:limit => @options[:limit]} : {}
    @type  = @options[:source_type] ? @options[:source_type] : :active_record
  end

  def add_storage_attribute
    symbol_attr = @options[:store_as].to_sym
    @from_table.first.class.class_eval do
      define_method(symbol_attr) do
        FutureStorage.instance[self.class.to_s][self.id][symbol_attr]
      end
    end
  end

  def new_destination_record(from_record)
      columns = @columns.inject({}) do |result, attributes|
        result[attributes[0]]= attributes[1].call(from_record)
        result
      end
      new_record = @to_table.new(columns)

      if @options[:validate]
        report_validation_errors(new_record, from_record, 'insert')
      else
        new_record.save(false)
        @current_operation.record_insert(new_record)
      end
      store_as(new_record, from_record)
  end

  def store_as(new_record, from_record)
    if @options[:store_as].present?
      @future_storage = FutureStorage.instance
      @future_storage[@from_table.to_s] ||= {}
      @future_storage[@from_table.to_s][from_record.id] ||= {}
      @future_storage[@from_table.to_s][from_record.id].merge!({@options[:store_as].to_sym => new_record})
    end
  end

  def report_validation_errors(new_record, from_record, type = 'insert')
    if new_record.save
      @current_operation.send("record_#{type}", new_record)
    else
      puts @current_operation.add_validation_error(new_record, from_record).pretty_output
    end
  end

end
include LegacyMigrations
include LegacyMigrations::Transformations
include LegacyMigrations::SourceIterators
include LegacyMigrations::RowMatchers

