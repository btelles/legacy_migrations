module LegacyMigrations
  module Transformations
    
    # Move data from the _from\_attribute_ in the 'from' table to a
    # column _:to_ in the 'to' table
    # 
    # ==== Options
    #
    # * <tt>:to</tt> - (Required) Column in destination table to fill in with value in 'from'
    # * <tt>&block</tt> - if passed a block, the block uses the value in the 'from_attribute'
    #   parameter and inserts the result of the block in the provided 'to' column.
    def from(from_attribute, *args)
      options = args.extract_options!
      if block_given?

        #anyone want to give this a try in another language? ;-)
        custom_method = Proc.new {|record| yield(record.send(from_attribute))}

        @columns.merge!({options[:to] => custom_method})
      else
        @columns.merge!( {options[:to] => from_attribute} )
      end
    end

    # Shortcut for transferring data between similar tables. 
    # For example, if two tables have a column named 'name', then using
    # this function will transfer data from source table's 'name' column
    # to the destination table's 'name' column.
    #
    # ==== Options
    #
    # * <tt>:only</tt> - Array of columns that you want to transfer, and 
    #   that have the same name on both tables.
    # * <tt>:except</tt> - Array of columns that you DON'T want to transfer,
    #   but that have the same name on both tables.
    def match_same_name_attributes(*options)

      options = options.extract_options!
      same_name_attributes = @from_table.columns.map(&:name) & @to_table.columns.map(&:name)

      if same_name_attributes
        same_name_attributes = columns_from_options(same_name_attributes, options)
        same_name_attributes.each do |same_name_attribute|
          from same_name_attribute, :to => same_name_attribute
        end
      end
    end

    private

    def columns_from_options(columns, options)
        columns.map!(&:to_sym)
        columns = columns.select {|a| options[:only].include?(a)} if options[:only]
        columns = columns.reject {|a| !options[:except].include?(a)} if options[:except]
        columns
    end
  end
end

