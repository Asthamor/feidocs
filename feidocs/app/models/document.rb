class Document < ApplicationRecord
  belongs_to :professor
  has_one_attached :docfile

  validates :docfile, presence: true
  validates :name, presence: true

  after_save :save_professors

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
    rescue
      end
  end

  #validate :docfile_validation
  #def docfile_validation
  #   if (! docfile. docfile.content_type.starts_with?('application/pd') or !docfile.content_type.starts_with?('application/vnd.openxmlformats-officedocument.wordprocessingml.documen'))
  #    docfile.purge
  #   errors[:base] << 'Formato incorrecto'
  # end
  #end

end