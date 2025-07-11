class RemovePasswordResetTokenFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :password_reset_token, :string
  end
end
