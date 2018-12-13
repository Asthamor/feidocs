class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|

      t.string :name, null: false, default: ""
      t.text :description, null: true

      t.timestamps
    end
  end
end
