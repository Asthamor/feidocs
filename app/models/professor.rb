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

  validates :fullName, presence: { message: ": El nombre completo del profesor es obligatorio" }, length: { minimum: 2, maximum: 255,
                                                 too_long: ": El máximo de caracteres permitidos es 255", too_short: ": El mínimo de caracteres permitidos es 2" },  format: { with: /\A[a-zA-Z]+\z/,
                                                                                                                                                                               message: ": Solo se permite letras" }
  validates :personalNumber, presence: { message: ": El número de personal es obligatorio" }, uniqueness: { message: ": El número de personal debe ser único" }, numericality: { only_integer: true , message: ": El número de personal debe ser conformado por números enteros" } , length: { maximum: 255,
                                                                                              too_long: ": El máximo de caracteres permitidos es %{count}" }


end
