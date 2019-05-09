require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table 
        table = <<-SQL
            CREATE TABLE dogs (
                id INT PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(table)
    end

    def self.drop_table
        table = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(table)
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    def save

        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]

        end
        self
    end

    def self.create(name:, breed:)
        x = self.new(name: name, breed: breed)
        x.save
        x
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        row = DB[:conn].execute(sql, id).flatten
        x = self.new(id: row[0], name: row[1], breed: row[2])
        x
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
              SELECT *
              FROM dogs
              WHERE name = ?
              AND breed = ?
              LIMIT 1
        SQL
    
        dog = DB[:conn].execute(sql, name, breed).flatten
        
        if !dog.empty?
          dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        row = DB[:conn].execute(sql, name).flatten
        x = self.new(id: row[0], name: row[1], breed: row[2])
        x
    end

end