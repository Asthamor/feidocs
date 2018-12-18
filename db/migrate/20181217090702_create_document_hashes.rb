class CreateDocumentHashes < ActiveRecord::Migration[5.2]
  def change
    create_table :document_hashes do |t|

      t.timestamps
    end
  end
end
