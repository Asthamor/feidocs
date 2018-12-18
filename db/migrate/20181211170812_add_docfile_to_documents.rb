class AddDocfileToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :docfile, :string
  end
end
