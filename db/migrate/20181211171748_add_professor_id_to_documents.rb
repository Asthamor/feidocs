class AddProfessorIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :professor, foreign_key: true
  end
end
