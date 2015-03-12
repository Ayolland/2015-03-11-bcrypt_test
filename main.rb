require 'pry'
require 'sinatra'
require 'sqlite3'
require 'giphy'
require 'bcrypt'
require 'active_record'

require_relative 'models/user.rb'

db_options = {adapter: 'sqlite3', database: 'users.db'}
ActiveRecord::Base.establish_connection(db_options)

before '/U/*' do
  if session[:username] == nil
    @display_error = "NOT LOGGED IN, BROSEPH!"
    erb :login
  end
end

get "/" do
  erb :login
end

get "/login" do
  erb :login
end

get "/U/:username" do
  erb :landing
end

post "/verify" do
  check_me = User.find_by name: params[:username].downcase
  check_me ||= User.new({password_hash: BCrypt::Password.create("SO_INCREDIBLY_INCONCIEVABLY_INCORRECT")})
  binding.pry
  if check_me.password == params[:password]
    session[:username] = params[:username]
    redirect to("/U/" + params[:username])
  else
    @display_error = "USERNAME/PASSWORD MISMATCH, PAL!"
    erb :login
  end
end

binding.pry