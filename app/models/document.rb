class Document < ApplicationRecord
  belongs_to :professor
  has_one_attached :docfile
  has_one_attached :firma
  has_many :collaborators
  attr_accessor :private_key
  attr_accessor :pass

  validates :name, presence: {message: ": El nombre del documento es obligatorio"}, length: {maximum: 255, too_long: "El número de caracteres máximo es de 255"}
  validates :description, presence: {message: ": La descripción es obligatoria"}, on: :create

  before_update :save_professors


  #custom setter
  def professors=(value)
    @professors = value
  end


  private

  def save_professors
    begin
    @professors.each do |professor_id|
      Collaborator.create(professor_id: professor_id, document_id: self.id)
    end

      end
  end

end