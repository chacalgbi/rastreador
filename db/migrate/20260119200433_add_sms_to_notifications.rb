class AddSmsToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_column :notifications, :sms, :string
  end
end
