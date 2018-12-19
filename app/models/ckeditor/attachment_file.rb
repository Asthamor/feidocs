class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_one_attached :data

  validates :data, presence: true
  
end
