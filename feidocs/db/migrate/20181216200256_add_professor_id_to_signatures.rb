class AddProfessorIdToSignatures < ActiveRecord::Migration[5.2]
  def change
    add_reference :signatures, :professor, foreign_key: true
  end
end
