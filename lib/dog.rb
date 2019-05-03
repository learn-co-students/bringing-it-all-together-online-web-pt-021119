require 'pry'

class Dog

attr_accessor :name, :breed
attr_reader :id

def initialize(hash)
  @id = hash[:id]
  @name = hash[:name]
  @breed = hash[:breed]
  self

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
  sql = <<-SQL
  DROP TABLE dogs
  SQL
  DB[:conn].execute(sql)
end

def save
  sql = <<-SQL
  INSERT INTO dogs (name, breed) VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs WHERE name = ?", self.name)[0][0]
  self
end

def self.create(hash)
  dogg = self.new(hash)
  dogg.save
  dogg
end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT id, name, breed FROM dogs WHERE id = ?
  SQL
  dogg = DB[:conn].execute(sql, id)[0]

  self.new(id: id, name: dogg[1], breed: dogg[2])

end

def self.find_or_create_by(name:, breed:)
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ? AND breed = ?
  SQL

  result = DB[:conn].execute(sql, name, breed)[0]

  if result
    self.find_by_id(result[0])
  else
    self.create(name: name, breed: breed)
    #binding.pry
  end
end

def self.new_from_db(row)
  self.new(id:row[0], name:row[1], breed:row[2])

end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ?
  SQL
  arry = DB[:conn].execute(sql, name)[0]
  self.find_by_id(arry[0])
end

def update
  sql = <<-SQL
  UPDATE dogs SET name = ?, breed = ? WHERE id = ?
  SQL

  DB[:conn].execute(sql, self.name, self.breed, self.id)

end

end
