class Dog 
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil , name: , breed:) 
    @id = id 
    @name = name 
    @breed = breed
  end 
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1 
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first  
  end 
  
  def update 
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self   
  end 
  
  def save 
    if self.id 
      self.update 
    else 
      sql = <<-SQL
        INSERT into dogs (name, breed) VALUES (?, ?) 
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end 
    self 
  end 
  
  def self.create(attributes)
    new_dog = self.new(name: nil, breed: nil)
    attributes.each { |key, value| new_dog.send("#{key}=", value) }
    new_dog.save
  end 
  
  def self.find_by_id(id) 
    dog_attributes = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new(id: id, name: dog_attributes[1], breed: dog_attributes[2])
  end 
  
  def self.find_or_create_by(name: , breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
    if !dog.empty?
      
      # dog is NOT empty, this dog exists in the db (empty? evaluates to false, !false is true)
      
      dog_attributes = dog[0]
      self.new(id: dog_attributes[0], name: dog_attributes[1], breed: dog_attributes[2])
   
    else
   
      # dog IS empty, this dog doesn't exist in the db (empty? evaluates to true, !true is false)
   
      new_dog = self.new(name: name, breed: breed)
      new_dog.save
      new_dog
    end  
  end 
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
end 