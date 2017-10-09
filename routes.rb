require 'sinatra'
require 'sinatra/cookies'
require 'mongoid'
require 'base64'
require 'digest'
require_relative 'models'

Mongoid.load!('mongoid.yml', :production)
set :port, 3000

before do
  begin
    @session = Session.find(cookies['session'])
    @user = @session.user
  rescue Mongoid::Errors::InvalidFind
    @session = @user = nil
  end
end

# Home
get '/' do
  @title = 'Inicio'
  erb :home
end

get '/contacto' do
  @title = 'Contacto'
  erb :contact
end

# Login page
get '/admin/login' do
  @title = 'Login'
  erb :login
end

# Signup
get '/admin/signup' do
  @title = 'Signup'
  erb :signup
end

get '/post/:id' do
  begin
    @post = Post.find(params[:id])
    @title = @post.title
  rescue Mongoid::Errors::DocumentNotFound
    @post = nil
    @title = 'Publicación no encontrada'
  end
  erb :post
end

# Signup
post '/auth/new' do
  [:email, :password].each do |e|
    return {:success=>0, :code=>1}.to_json unless params.include? e
  end
  return {:success=>0, :code=>2}.to_json if User.where(:email=>params[:email]).exists

  salt = SecureRandom.base64
  value = Digest::SHA2.new(512).hexdigest(params[:password] + salt)

  user = User.create(
      email: params[:email],
      password: { salt: salt, value: value}
  )

  {:success=>1, :id=>user.id.to_s}.to_json
end

# Login
post '/auth/open' do
  [:email, :password].each do |e|
    return {:success=>0, :code=>1}.to_json unless params.include? e
  end
  return {:success=>0, :code=>2}.to_json unless User.where(:email=>params[:email]).exists

  user = User.where(email: params[:email]).first
  salt = user.password[:salt]
  value = Digest::SHA2.new(512).hexdigest(params[:password] + salt)

  return {:success=>0, :code=>3}.to_json unless value == user.password[:value]

  session = user.sessions.build(ip: request.ip)
  user.save

  {:success=>1, :id=>session.id.to_s}.to_json
end