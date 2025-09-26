class AddUniqueIndexToPushSubscriptionsEndpoint < ActiveRecord::Migration[8.0]
  def change
    add_index :push_subscriptions, :endpoint, unique: true
  end
end
