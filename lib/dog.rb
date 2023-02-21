require 'sqlite3'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = attributes[:id]
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
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
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.new_from_db(row)
    attributes = {
      id: row[0],
      name: row[1],
      breed: row[2]
    }
    Dog.new(attributes)
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
    rows = DB[:conn].execute(sql)
    rows.map { |row| self.new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row) if row
  end

  def self.find(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id).first
    self.new_from_db(row) if row
  end
end
