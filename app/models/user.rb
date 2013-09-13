class User < ActiveRecord::Base
  attr_accessible :email, :name, :password_digest, :auth_token
  validates :name, presence: true
  
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
  					format: { with: EMAIL_REGEX },
  					uniqueness: { case_sensitive: false }

  before_save { self.email = email.downcase }

  has_secure_password
end
