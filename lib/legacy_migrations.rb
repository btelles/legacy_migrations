require 'legacy_migrations/transformations'
module LegacyMigrations

  # Define a source and destination table to transfer data
  #
  # ==== Options
  #
  # * <tt>:to</tt> - (Required) Class of the destination table
  # * <tt>:limit</tt> - Set a limit to the number of rows to transfer.
  #   This is useful when you're trying to find faulty data in the source
  #   table, and don't want to run the entire dataset.
  #  
  def transfer_from(from_table, *args, &block)
    @columns = {}

    options = args.extract_options!

    @from_table = from_table
    @to_table = options[:to]

    yield
    limit = options[:limit] ? {:limit, options[:limit]} : {}
    @from_table.all(limit).each do |from_record|
      columns = @columns.inject({}) do |result, attributes|
        if attributes[1].instance_of?(Proc)
          result[attributes[0]]= attributes[1].call(from_record)
        else
          result[attributes[0]]= from_record.send(attributes[1])
        end
        result
      end
      new_record = @to_table.new(columns)
      new_record.save
    end
  end

end
include LegacyMigrations
include LegacyMigrations::Transformations
