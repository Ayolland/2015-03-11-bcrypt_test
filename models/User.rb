DATABASE = SQLite3::Database.new("slides.db")
DATABASE.execute("CREATE TABLE IF NOT EXISTS users ( id INTEGER PRIMARY KEY, name TEXT, password_hash TEXT)")

# ^ This is not a great place for your database setup, nor is it a great way to
#   do this. But it demonstrates what the database looks like, so we know what
#   our User objects look like. If you wanted to do this with Active Records,
#   can, look up Active Records Migrations.
#   NOTE WE DON'T HAVE A PASSWORD COLUMN

db_options = {adapter: 'sqlite3', database: 'users.db'}
ActiveRecord::Base.establish_connection(db_options)

# ^ This is how ActiveRecords knows where your db is and what kind it is ^

class User < ActiveRecord:: Base
  
  # There are no save, insert, initialize methods here because ActiveRecords is
  # handling all of them. This only works because in users.db, which we
  # connected to in main.rb, has a column for each attribute which our User
  # objects have by default. 
  
  include BCrypt
  
  # Adding the BCrypt module to the User object, so we can use Password objects.
  
  def password
    @password ||= Password.new(password_hash)
  end
  
  # When we type some_user.password, this method returns the @password
  # attribute, or if that is not set, it sets it to a new Password object using 
  # the password_hash attribute found in the database when the some_user was 
  # initialized. A Password object can quickly decrypt a password_hash through
  # magic.
  
  # NOTE: Password.new is for making a Password object out of a hash.

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  # When some_user.password= is called, this method sets @password to a Password
  # object by encrypting the string given as an argument.
  # some_user.password_hash is set to that same Password object, and will be
  # converted into a string of the hash when some_user.save is run.
  
  # NOTE: Password.create is for making a Password object out of a non-hash 
  # string.
end