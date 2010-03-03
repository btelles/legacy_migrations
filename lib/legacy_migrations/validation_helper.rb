module LegacyMigrations
  module ValidationHelper
    def report_validation_errors(new_record, from_record)
      unless new_record.save
        puts "Validation error saving new record. Invalid columns:"
        new_record.errors.each do |attr, error|
          puts "     #{attr} in the new record #{error}"
          puts "     Value of #{attr}: #{new_record.send(attr.to_sym)}"
        end
        puts "     Source record: #{from_record.inspect}"
      end
    end
  end
end
