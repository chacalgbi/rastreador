class ChangeEmailAddressToNullableInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :email_address, true
  end
end
