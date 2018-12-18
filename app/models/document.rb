class Document < ApplicationRecord
  belongs_to :professor
  has_one_attached :docfile
  has_one_attached :firma
  has_many :collaborators
  attr_accessor :private_key
  attr_accessor :pass

  validates :name, presence: true
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