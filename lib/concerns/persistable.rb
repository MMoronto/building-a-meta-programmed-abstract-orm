module Persistable
  
module ClassMethods
  def self.table_name
    "#{Post.to_s.downcase}s"
  end 

  def self.find(id)
    sql = <<-SQL
      SELECT * FROM "#{self.table_name}" WHERE id = ?
    SQL

    rows = DB[:conn].execute(sql, id)
    self.reify_from_row(row.first)
  end

  def self.reify_from_row(row)
    self.new.tap do |p|
      p.id = row[0]
      p.title = row[1]
      p.content = row[2]
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS "#{self.table_name}" (
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.attribute_names_for_insert
    ATTRIBUTES.keys[1..-1].join(",")
  end

  def self.question_marks_for_insert 
    (ATTRIBUTES.keys.size-1).times.collect{"?"}.join(",")
  end

  def self.sql_for_update 
    "title = ?, content = ?"
    (ATTRIBUTES.keys.size-1).times.collect{|attribute_name| "#{attribute_name} = ?"}.join(",")
  end 

  end

  
  module instanceMethods
    def destroy
    sql = <<-SQL 
      DELETE FROM "#{self.class.table_name}" WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.id)
  end


  def save
    # If the post has been saved before, then call update
    persist? ? update : insert
    #othjerwise call insert
  end

  def ==(other_post)
    self.id == other_post.id
  end

  def persisted?
    !!self.id
  end

    def insert
      sql = <<-SQL
        INSERT INTO "#{self.class.table_name}" ("#{self.class.attribute_names_for_insert}") VALUES ("#{self.question_marks_for_insert}")
      SQL 

      DB[:conn].execute(sql, *attribute_values)
      self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
    end

    def update
      sql = <<-SQL
        UPDATE posts SET "#{self.class.sql_for_update}" WHERE id = ?
      SQL

      DB[:conn].execute(sql, *attribute_values, self.id)
    end

    def attribute_values 
      ATTRIBUTES.keys[1..-1].collect{|attribute_name| self.send(attribute_name)}
    end

  end

end
