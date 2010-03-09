module LegacyMigrations
  module SourceIterators
    def source_iterator(limit, type, &block)
      if type == :active_record
        @from_table.all(limit)
      elsif type == :csv
        if limit[:limit]
          fewer_rows = []
          rows_processed = 0
          @from_table.each do |row|
            fewer_rows << row
            rows_processed += 1
            break if rows_processed == limit[:limit].to_i
          end
          FasterCSV::Table.new(fewer_rows)
        else
          @from_table
        end
      end
    end
  end
end
