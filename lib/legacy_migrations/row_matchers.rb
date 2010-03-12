module LegacyMigrations
  module RowMatchers
    
    # Use 'based_on' to match a destination record with a 
    # source record when running an update.
    #
    # This uses the matching syntax available in Thoughtbot's 
    # Squirrel plugin where the left operator is the destination
    # field name, and the right-hand operator is usually
    # the source row and method.
    #
    # === Example
    #
    #   based_on do |from|
    #     name == from.name
    #     age > 17
    #   end
    #
    # The above says that if we have a destination row 
    # whose name attribute matches a source (from) row's name,
    # and the destination row has an age > 17, then assume the
    # source row and destination row are the same record, and update
    # the destination row with the source row's data
    #
    # See the thoughtbot documentation for more details 
    # about the squirrel syntax at:
    # http://github.com/thoughtbot/squirrel/
    def based_on(&blk)
      @blck = blk
      @conditions = Proc.new {|from| 
        @from = from
        query = LegacyMigrations::Squirrel::Query.new(@to_table, from, &@blck)
        query.execute(:all)
      }
    end
  end
end

