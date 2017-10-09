require 'sinatra'
require 'sinatra/cookies'
require_relative 'models'

set :port, 3000

before do
  @session = Session.where(id: BSON::ObjectId.from_string(cookies['session'])).first
  @user = @session.user
end

# Home
get '/' do
  @title = 'Home'
  erb :home
end

# Signup/login page
get '/account' do
  @title = 'Account'
  erb :account
end

get '/post/:id' do

end

post '/auth/new' do

  {:success=>1}.to_json
end

post '/auth/open' do
  {:success=>1}.to_json
end