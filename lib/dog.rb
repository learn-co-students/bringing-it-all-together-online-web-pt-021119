class Dog
    attr_accessor :name, :breed, :id

    def initialize (name:, breed:, id:nil)
        @name=name
        @breed=breed
        @id=id
    end
    
    def self.create_table
        sql="CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql="DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql="INSERT INTO dogs (name, breed) VALUES (?,?)"
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash_1)
        dog=Dog.new(name:hash_1[:name],breed:hash_1[:breed],id:hash_1[:id])
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql="SELECT * FROM dogs WHERE id=?"
        row=DB[:conn].execute(sql,id)[0]
        Dog.new(name:row[1],breed:row[2],id:row[0])
    end
    
    def self.find_or_create_by (name:, breed:)
        sql="SELECT * FROM dogs WHERE name=? AND breed=?"
        row=DB[:conn].execute(sql,name,breed)[0]
        !row ? dog=create({name:name, breed:breed, id:nil}) : dog=find_by_id(row[0])
    end

    def self.new_from_db(row)
        dog=Dog.new(name:row[1],breed:row[2],id:row[0])
    end

    def self.find_by_name(name)
        sql="SELECT * FROM dogs WHERE name=?"
        row=DB[:conn].execute(sql,name)[0]
        Dog.new(name:row[1],breed:row[2],id:row[0])
    end

    def update
        sql="UPDATE dogs SET name=?, breed=? WHERE id=?"
        DB[:conn].execute(sql,self.name,self.breed,self.id)
    end
end