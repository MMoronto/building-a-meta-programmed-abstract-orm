class Author

  ATTRIBUTES = {
      :id => "INTEGER PRIMARY KEY",
      :name => "TEXT",
      :state => "TEXT",
      :city => "TEXT",
      :age => "INTEGER"
    }


  #DO NOT EDIT ANYTHING BELOW THIS

    ATTRIBUTES.keys.each do |attribute_name| 
      attr_accessor attribute_name
    end

    def destroy
      sql = <<-SQL 
        DELETE FROM "#{self.class.table_name}" WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.id)
    end

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
