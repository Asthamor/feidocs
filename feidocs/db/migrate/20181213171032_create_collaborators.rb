class CreateCollaborators < ActiveRecord::Migration[5.2]
  def change
    create_table :collaborators do |t|
      t.references :document, foreign_key: true
      t.references :professor, foreign_key: true

      t.timestamps
    end
  end
end
