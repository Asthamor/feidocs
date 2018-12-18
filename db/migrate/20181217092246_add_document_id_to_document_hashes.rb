class AddDocumentIdToDocumentHashes < ActiveRecord::Migration[5.2]
  def change
    add_reference :document_hashes, :document, foreign_key: true
  end
end
