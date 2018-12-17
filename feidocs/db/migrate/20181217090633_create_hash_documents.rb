class CreateHashDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_documents do |t|

      t.timestamps
    end
  end
end
