require 'legacy_migrations/transformations'
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
  #   when saving destination data.
  # * <tt>:source_type</tt> - Default = :active_record. Sets the source
  #   destination type.
  #   Options:
  #   _:active_record_: Assumes the From option is a class that inherits
  #   from ActiveRecord::Base, then iterates through each record of From
  #   table by using *From*.all.each...
  #   _:other_: Assumes the From option is an iterable 'collection' whose 
  #   elements/items can respond to all columns speficied in the given block.
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
    @status_report = StatusReport.instance

    yield

    @limit = @options[:limit] ? {:limit, @options[:limit]} : {}
    @type  = @options[:source_type] ? @options[:source_type] : :active_record
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

