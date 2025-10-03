class AddInfoToPushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :push_subscriptions, :info, :string
  end
end
