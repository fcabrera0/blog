require 'mongoid'

class User
  include Mongoid::Document

  field :email, type: String
  field :name, type: String
  field :role, type: Array, default: ['reader']
  field :password, type: Hash
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  has_many :sessions
  has_many :posts

  accepts_nested_attributes_for :posts
  accepts_nested_attributes_for :sessions
end

class Session
  include Mongoid::Document

  field :ip, type: String
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  belongs_to :user
end

class Post
  include Mongoid::Document

  field :title, type: String
  field :content, type: String
  field :tags, type: Array
  field :timestamp, type: DateTime, default: ->{ DateTime.now }

  belongs_to :user
end

class Comment
  include Mongoid::Document
  field :content, type: String
  field :timestamp, type: DateTime, default: ->{ DateTime.now }
  belongs_to :user
end