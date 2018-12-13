class Document < ApplicationRecord
  has_one_attached :docfile

  validates :docfile, presence: true
  validate :docfile_validation

  def docfile_validation
      if (! docfile. docfile.content_type.starts_with?('application/pd') or !docfile.content_type.starts_with?('application/vnd.openxmlformats-officedocument.wordprocessingml.documen'))
        docfile.purge
        errors[:base] << 'Formato incorrecto'
    end
  end

end