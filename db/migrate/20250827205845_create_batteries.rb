class CreateBatteries < ActiveRecord::Migration[8.0]
  def change
    create_table :batteries do |t|
      t.string :device_id
      t.string :device_name
      t.string :user_id
      t.string :user_name
      t.string :bat
      t.string :bkp

      t.timestamps
    end
  end
end
