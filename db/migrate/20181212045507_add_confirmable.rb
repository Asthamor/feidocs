class AddConfirmable < ActiveRecord::Migration[5.2]
  def up
   # add_column :professors, :confirmation_token, :string
   # add_column :professors, :confirmed_at, :datetime
   # add_column :professors, :confirmation_sent_at, :datetime
    # add_column :professors, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :professors, :confirmation_token, unique: true
    # User.reset_column_information # Need for some types of updates, but not for update_all.
    # To avoid a short time window between running the migration and updating all existing
    # professors as confirmed, do the following
    Professor.update_all confirmed_at: DateTime.now
    # All existing user accounts should be able to log in after this.
  end

  def down
    remove_columns :professors, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # remove_columns :professors, :unconfirmed_email # Only if using reconfirmable
  end
end
