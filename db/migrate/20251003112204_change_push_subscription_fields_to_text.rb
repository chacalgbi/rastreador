class ChangePushSubscriptionFieldsToText < ActiveRecord::Migration[8.0]
  def up
    remove_index :push_subscriptions, :endpoint

    change_column :push_subscriptions, :endpoint, :text
    change_column :push_subscriptions, :p256dh, :text
    change_column :push_subscriptions, :auth, :text

    add_index :push_subscriptions, :endpoint, unique: true, length: 700
  end

  def down
    remove_index :push_subscriptions, :endpoint

    change_column :push_subscriptions, :endpoint, :string
    change_column :push_subscriptions, :p256dh, :string
    change_column :push_subscriptions, :auth, :string

    add_index :push_subscriptions, :endpoint, unique: true
  end
end
