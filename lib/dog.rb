require 'pry'

class Dog 
  attr_accessor :name, :breed, :id

  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
    @id = args[:id]
  end
  
  def self.create_table
    sql_table = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL
    
    DB[:conn].execute(sql_table)
  end

  def self.drop_table
    sql_table = <<-SQL
    DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql_table)
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end
  
  def save
    sql_save = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    if self.id
      self.update
    else
      DB[:conn].execute(sql_save, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(args)
    dog = Dog.new(args)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql_query = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      LIMIT 1
    SQL
    
    DB[:conn].execute(sql_query,id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(args)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", args[:name], args[:breed])
    
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(args)
    end 
    dog
  end
  
  def self.find_by_name(name)
    sql_query = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql_query,name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql_query = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql_query,self.name, self.breed, self.id)
  end
end