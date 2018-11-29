class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|

      t.string :name, null: false, default: ""
      t.string :path, null: true, default: ""
      t.string :mimeType, null: false, default: ""

      t.timestamps
    end
  end
end
