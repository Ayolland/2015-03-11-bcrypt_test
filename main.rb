require 'pry'
require 'sinatra'
require 'sqlite3'
require 'giphy'
require 'bcrypt'
require 'active_record'

require_relative 'models/user.rb'

enable :sessions

# ^ Without this, session will always be an empty hash. We need sessions to    
#   store data between pageviews.

before '/:name/*' do
  redirect to ("/wrong_login") if session[:name] != params[:name]
end

# ^ session[:name] is set to the name field of the user object when a user
#   logs in. This test to make sure session[:name] is not nil and is the right
#   user.

get "/" do
  if session[:name]
    redirect to("/#{session[:name]}/")
  else
    redirect to("/login")
  end
end

# ^ Main route.  Redirects based on if user has a session already open. ^

get "/login" do
  erb :login
end

# ^ These routes just provide easy access to the login page. ^

get "/:name/" do
  erb :landing
end

# ^ This is where the user will end up after they login. ^

get "/wrong_login" do
  session[:name] = nil
  @display_msg = "YOU'RE NOT LOGGED IN AS THAT USER, YO"
  erb :login
end

# ^ If authentication fails, the user is sent here. ^

get "/logout" do
  session[:name] = nil
  @display_msg = "YOU'VE BEEN LOGGED OUT."
  erb :login
end

# ^ Clears the session and returns to the login page. ^

get "/username_taken" do
  session[:name] = nil
  @display_msg = "THAT USERNAME ALREADY EXISTS."
  erb :login
end

# ^ Just explains that the username cannot be used again. ^

post "/new_user" do
  # ^ Using post to hide password data.
  all_in_lowercase(params) # this a method in the helpers module below.
  # ^ By converting it all to lowercase, username and passwords are not case
  #   sensitive, and are harder to get wrong by mistake.
  binding.pry
  redirect to ("username_taken") if (User.find_by name: params[:name]) != nil
  # ^ User.find_by uses ActiveRecords to return the FIRST User with a name field
  #   that matches params[:name]. If a user with that name already exists, and a
  #   new user is created, User.find_by will NEVER find the second user. So we
  #   need to prevent this from happening.
  new_user = User.new(params)
  # ^ Creates a new User object using params and ActiveRecords.
  new_user.save
  # ^ Saves that User object to the database.
  @display_msg = "USER CREATED, TRY LOGGING IN NOW."
  erb :login
end

post "/verify" do
  all_in_lowercase(params) # this a method in the helpers module below.
  # ^ You have to convert it to lowercase when checking, too.
  check_me = User.find_by name: params[:name]
  # ^ Pulls the first User record with a matching name, sets it to check_me
  check_me ||= User.new({password_hash: BCrypt::Password.create("SO_INCREDIBLY_INCONCIEVABLY_INCORRECT")})
  # ^ There are several things going on here. First of all, we don't want
  #   check_me to be nil, because nil.password makes no sense. So we use
  #   OR-EQUALS, which will only set check_me if check me is nil. We need a user
  #   object with a password, but not one with a real password so you can't
  #   freak accident. Any string will do here, but I put a really long one in so
  #   that the chances of picking it are astronomical. Lastly, we're using the
  #   BCrypt.create method to make a new Password object out of the long string.
  
  #   NOTE THAT WE ARE SETTING THE PASSWORD TO password_hash, AND NOT PASSWORD.
  #   THERE IS NO password COLUMN IN OUR users TABLE.
  if check_me.password == params[:password]
    # ^ We can evaluate the password object against the string that generated
    #   it, because BCrypt re-writes the == method for Password objects. In
    #   order for this to work, The password object needs to be on the left 
    #   side.
    session[:name] = params[:name]
    # ^ if the password matches, we can set session[:name]. Our user is now
    #   authenticated!
    redirect to("/" + params[:name] + "/")
    # ^ And we redirect them to their page.
  else
    @display_msg = "USERNAME/PASSWORD MISMATCH, PAL!"
    erb :login
    # ^ Otherwise the password doesn't match, and we send them back to login.
  end
end

helpers do
  def all_in_lowercase(hash)
    hash.each{|k,v| hash[k] = v.downcase if v.is_a?(String)}
  end
  # ^ So, this just helps us convert to lowercase. Take each key/value and if
  #   the value is a string, set the value in the hash to a lowercase version.
end
