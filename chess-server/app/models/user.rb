class User < ApplicationRecord
  
  devise :database_authenticatable, :rememberable, :token_authenticatable
  has_many :authentication_tokens
end
