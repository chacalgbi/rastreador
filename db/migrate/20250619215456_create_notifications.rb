class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.text :whatsapp
      t.text :email
      t.text :telegram

      t.timestamps
    end
  end
end
