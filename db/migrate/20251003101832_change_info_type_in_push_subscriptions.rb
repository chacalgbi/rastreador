class ChangeInfoTypeInPushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    change_column :push_subscriptions, :info, :text
  end
end
