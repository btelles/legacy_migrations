module LegacyMigrations
  module Transformations
    
    # Move data from the _from\_attribute_ in the 'from' table to a
    # column _:to_ in the 'to' table
    # 
    # ==== Options
    #
    # * <tt>:to</tt> - (Required) Column in destination table to fill in with value in 'from'
    # * <tt>:if</tt> - specify a function that takes one parameter (the source table's RECORD)
    #   and returns true or false. The assignment is only made if the function returns a
    #   non-false value.
    # * <tt>&block</tt> - if passed a block, the block takes one parameter,
    #   which is the value of the attribute in the _from_ parameter, then inserts the result of
    #   the block into the destination attribute.
    #   parameter and inserts the result of the block in the provided 'to' column.
    # * <tt>:from_record</tt> - If you set the "from" column to "from_record",
    #   the variable passed into the block will be the entire from record,
    #   instead of just one of its columns
    def from(from_attribute, *args)
      options = args.extract_options!

      if options[:if]
        if_method = Proc.new {|record| send(options[:if], record)}
      else
        if_method = Proc.new {|record| true }
      end
      #anyone want to give this a try in another language? ;-)
      custom_method = Proc.new {|record| 
        if if_method.call(record)
          case
          when block_given? && from_attribute == :from_record
            yield(record)
          when block_given?
            yield(record.send(:[], from_attribute.to_s))
          else
            record.send(:[], from_attribute.to_s)
          end
        else
          nil
        end

      }

      @columns.merge!({options[:to] => custom_method})
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

