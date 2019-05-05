class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    @id  = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def last_id
    DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    attributes = {id: self.last_id, name: name, breed: breed}
    self.class.new(attributes)
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    dog_find = DB[:conn].execute(sql, id).flatten
    dog_find_attributes = {id: dog_find[0], name: dog_find[1], breed: dog_find[2]}
    self.new(dog_find_attributes)
  end

  def self.find_or_create_by(attributes)
    name = attributes[:name]
    breed = attributes[:breed]
    sql = <<-SQL
    SELECT id FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog_find = DB[:conn].execute(sql, name, breed).flatten
    if !!!dog_find[0]
      self.create(attributes)
    else
      dog_find_attributes = {id: dog_find[0], name: name, breed: breed}
      self.new(dog_find_attributes)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0],name: row[1],breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    dog_find = DB[:conn].execute(sql, name).flatten
    dog_find_attributes = {id: dog_find[0], name: dog_find[1], breed: dog_find[2]}
    self.new(dog_find_attributes)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    update_attr = {id: self.id, name: self.name, breed: self.breed}
    self.class.new(update_attr)
  end

end
