require 'sinatra'
require 'sinatra/cookies'
require 'mongoid'
require 'base64'
require 'digest'
require 'redcarpet'
require_relative 'models'

Mongoid.load!('mongoid.yml', :production)
set :port, 3000

class MdRenderer < Redcarpet::Render::HTML

end

before do
  @mdparser = Redcarpet::Markdown.new(MdRenderer)
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
  @posts = Post.where(:status.gte => 0)
  erb :home
end

get '/contacto' do
  @title = 'Contacto'
  erb :contact
end

post '/contacto' do
  [:name, :email, :subject, :content].each do |e|
    return {:success=>0, :code=>1}.to_json unless params.include? e
  end
  Contact.create(
      name: params[:name],
      email: params[:email],
      subject: params[:subject],
      content: params[:content]
  )
  redirect '/'
end

# Login page
get '/admin/login' do
  @title = 'Ingreso'
  @r = params[:r] || '/'
  erb :login
end

# Signup
get '/admin/signup' do
  @title = 'Registro'
  erb :signup
end

get '/admin/dashboard' do
  redirect "/admin/login?r=#{request.fullpath}" if @user.blank?
  @posts = @user.posts
  @title = 'Dashboard'
  erb :dashboard
end

# Get a post
get '/post' do
  begin
    @post = Post.find(params[:id])
    @title = @post.title
    @by = @post.user
    @post.views += 1
    @post.save
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    @post = nil
    @title = 'Publicación no encontrada'
  end
  erb :post
end

get '/preview' do
  @title = params[:title]
  @brief = params[:brief]
  @content = params[:content]
  erb :preview
end

post '/post' do
  [:title, :brief, :content, :tags].each do |e|
    return {:success=>0, :code=>1}.to_json unless params.include? e
  end
  return {:success=>0, :code=>2}.to_json if @user.blank? or not @user.role.include? 'creator'

  p = @user.posts.build(
      title: params[:title],
      brief: params[:brief],
      content: params[:content],
      tags: params[:tags]
  )

  @user.save

  return {:success=>1, :id=>p.id.to_s}.to_json
end

# Edit a post
get '/post/edit' do
  redirect "/admin/login?r=#{request.fullpath}" if @user.blank?

  begin
    @post = Post.find(params[:id])
    @title = @post.title
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    @post = nil
    @title = 'Publicación no encontrada'
  end
  erb :edit
end

# Compose a post
get '/post/new' do
  redirect "/admin/login?r=#{request.fullpath}" if @user.blank?

  @title = 'Nueva publicación'
  erb :compose
end

# Signup
post '/auth/new' do
  [:email, :password].each do |e|
    return {:success=>0, :code=>1}.to_json unless params.include? e
  end
  return {:success=>0, :code=>2}.to_json if User.where(:email=>params[:email]).exists?

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
  return {:success=>0, :code=>2}.to_json unless User.where(:email=>params[:email]).exists?

  user = User.where(email: params[:email]).first
  salt = user.password[:salt]
  value = Digest::SHA2.new(512).hexdigest(params[:password] + salt)

  return {:success=>0, :code=>3}.to_json unless value == user.password[:value]

  session = user.sessions.build(ip: request.ip)
  user.save

  {:success=>1, :id=>session.id.to_s}.to_json
end