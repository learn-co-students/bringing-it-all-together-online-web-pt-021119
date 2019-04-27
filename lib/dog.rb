require "pry"
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
    self
  end

  def self.create(dog_hash)
    dog = Dog.new(name: dog_hash[:name], breed: dog_hash[:breed])
    dog.save
  end

  def self.find_by_id(id)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id=?", id).flatten
    Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end

def self.find_or_create_by(dog_stuff)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", dog_stuff[:name], dog_stuff[:breed])
  if !dog.empty?
    Dog.find_by_id(dog.flatten[0])
  else
    Dog.create(dog_stuff)
  end
end

def self.new_from_db(row)
  new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
end

def self.find_by_name(name)
  new = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
  Dog.new_from_db(new)
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end
