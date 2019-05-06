class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL

    saved_dog = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.new_from_db(row)
    attributes = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    self.new(attributes)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    found_dog = DB[:conn].execute(sql, name, breed).first
    if found_dog
      new_dog = self.new_from_db(found_dog)
    else
      new_dog = self.create({:name => name, :breed => breed})
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
