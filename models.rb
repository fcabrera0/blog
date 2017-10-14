require 'mongoid'

class User
  include Mongoid::Document

  field :email, type: String
  field :name, type: String
  field :password, type: Hash
  field :role, type: Array, default: ['reader']
  field :status, type: Integer, default: 0
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  has_many :sessions
  has_many :posts

  accepts_nested_attributes_for :posts
  accepts_nested_attributes_for :sessions
end

class Session
  include Mongoid::Document

  field :ip, type: String
  field :status, type: Integer, default: 0
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  belongs_to :user
end

class Post
  include Mongoid::Document

  field :title, type: String
  field :content, type: String
  field :tags, type: Array
  field :views, type: Integer, default: 0
  field :status, type: Integer, default: 0
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  belongs_to :user
end

class Media
  include Mongoid::Document

  field :mime, type: String
  field :file, type: String
  field :descr, type: String
  field :timestamp, type: DateTime, default: ->{ DateTime.now }
end

class Comment
  include Mongoid::Document

  field :content, type: String
  field :status, type: Integer, default: 0
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  belongs_to :user
end

class Contact
  include Mongoid::Document

  field :name, type: String
  field :email, type: String
  field :subject, type: String
  field :content, type: String
end