module LegacyMigrations

  #The StatusReport is returned from each transfer_from and update_from
  #function. Its purpose is to keep track of all the operations
  #you've done so far, and to help you log information about them 
  #after they are complete.
  #
  #Each status report has a many operations (one for each transfer or update)
  #
  #Each Operation has a source, destination, type (transfer or update),
  #inserts (array of records inserted), updates (array of records updated),
  #validation errors, sequence and source type.
  #
  class StatusReport
    include Singleton
    attr_reader :operations, :sequence

    def add_operation(args)
      @sequence ? @sequence += 1 : @sequence = 1
      @operations ||= []
      operation = Operation.new(args.merge({:sequence => @sequence}))
      @operations << operation
      operation
    end

    def operation_with(*args)
      @operations ||= []
      @operations.select do |operation|
        result = true
        args.last.each do |property, value|
          result = false unless operation.send(property) == value
        end
        result
      end[0]
    end
  end

  class ValidationError
    attr_accessor :source_record, :destination_record, :errors
    def initialize(destination_record, source_record)
      @source_record = source_record.dup
      @destination_record = destination_record.dup
      @errors = @destination_record.errors.dup
    end
    def pretty_output
      puts "Validation error saving record. Invalid columns:"
      @errors.each do |attr, error|
        puts "     #{attr} in the new record #{error}"
        puts "     Value of #{attr}: #{@destination_record.send(attr.to_sym)}"
      end
      puts "     Source record: #{@source_record.inspect}"
    end
  end

  class Operation
    attr_accessor :source, :destination, :source_type, 
                  :sequence, :inserts, :updates,
                  :validation_errors, :type

    def initialize(properties)
      properties.each do |property, value|
        send("#{property.to_s}=", value) if respond_to? "#{property.to_s}="
      end
    end

    def record_update(updated_record)
      @updates ||= []
      @updates << updated_record
    end

    def record_insert(new_record)
      @inserts ||= []
      @inserts << new_record

    end

    def add_validation_error(new_record, from_record)
      @validation_errors ||= []
      validation_error = ValidationError.new(new_record, from_record)
      @validation_errors << validation_error
      validation_error
    end

    def description
      inserts = @inserts.try(:size) || 0
      updates = @updates.try(:size) || 0
      insert_phrase = "#{inserts} #{inserts == 1 ? 'insert' : 'inserts'}"
      update_phrase = "#{updates} #{updates == 1 ? 'update' : 'updates'}"
      actions = [insert_phrase, update_phrase].join(' and ') << '.'
      "#{@type.capitalize} of data from #{@source.to_s.pluralize} to #{@destination.to_s.pluralize} resulted in #{actions}"
    end
  end

end
