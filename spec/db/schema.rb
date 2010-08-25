 ActiveRecord::Schema.define(:version => 0) do 

  create_table :people, :force => true do |t|
    t.string :name
    t.string :not_name
    t.string :city
    t.integer :age
  end

  create_table :animals, :force => true do |t|
    t.string :name
    t.string :not_name
    t.integer :age 
    t.string :first_name
    t.integer :city_id
  end

  create_table :sex, :force => true do |t|
    t.string :name
  end

  create_table :cities, :force => true do |t|
    t.string :name
  end

end

