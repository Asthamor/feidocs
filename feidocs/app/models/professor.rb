class Professor < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one_attached :photo

  has_many :messages
  has_many :conversations, foreign_key: :sender_id

  has_many :collaborators
  has_many :documents, through: :collaborators

  has_one :signature
end
