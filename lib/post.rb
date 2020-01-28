class Post
  attr_accessor :id, :title, :content

  def self.table_name
    "#{Post.to_s.downcase}s"
  end 

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name} (
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT
      )
    SQL
    DB[:connection].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (title, content) VALUES (?, ?)
    SQL 

    DB[:conn].execute(sql, self.title, self.content)
  end

end 