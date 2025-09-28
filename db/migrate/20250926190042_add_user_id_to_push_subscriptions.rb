class AddUserIdToPushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :push_subscriptions, :user_id, :integer
  end
end
