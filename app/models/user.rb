class User < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
