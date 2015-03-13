DATABASE = SQLite3::Database.new("slides.db")
DATABASE.execute("CREATE TABLE IF NOT EXISTS users ( id INTEGER PRIMARY KEY, name TEXT, password_hash TEXT)")

db_options = {adapter: 'sqlite3', database: 'users.db'}
ActiveRecord::Base.establish_connection(db_options)

# ^ This is how ActiveRecords knows where your db is and what kind it is ^

class User < ActiveRecord:: Base
  
  # There are no save, insert, initialize methods here because ActiveRecords is
  # handling all of them. This only works because in users.db, which we
  # connected to in main.rb, has a column for each attribute which our User
  # objects have by default. In that table, there are a
  
  include BCrypt
  
  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
end