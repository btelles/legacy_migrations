module LegacyMigrations
  module Transformations
    def from(from_attribute, *args)
      options = args.extract_options!
      @columns.merge!( {options[:to] => from_attribute} )
    end

    def match_same_name_attributes

      same_name_attributes = @from_table.columns.map(&:name) & @to_table.columns.map(&:name)

      if same_name_attributes
        same_name_attributes.map(&:to_sym).each do |same_name_attribute|
          from same_name_attribute, :to => same_name_attribute
        end
      end
    end
  end
end

