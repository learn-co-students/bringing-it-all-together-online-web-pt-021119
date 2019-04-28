class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
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

  end

  def self.create(name:, breed:)
  end

  def self.find_by_id(id)
  end

  def self.find_or_create_by(name)
  end

  def self.new_from_db(row)
  end

  def self.find_by_name(name)
  end

  def update
  end

end
