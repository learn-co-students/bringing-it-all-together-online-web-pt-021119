class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
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
      INSERT INTO dogs
      (name, breed) VALUES
      (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name_arg)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name_arg).map do |row|
      self.new(id: row[0], name: row[1], breed: row[2])
    end.first
  end

  def self.find_by_id(id_arg)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id_arg).map do |row|
      self.new(name: row[1], breed: row[2], id: row[0])
    end.first
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog_info = dog[0]
      dog = self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(hash)
    end
    dog
  end

end
