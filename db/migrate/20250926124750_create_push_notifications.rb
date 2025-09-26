class CreatePushNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :push_notifications do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
