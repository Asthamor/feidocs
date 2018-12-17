class DocumentHash < ApplicationRecord
  has_one_attached :hash
  validates :document_id, uniqueness: {message: "Solo una firma por documento" }

end
