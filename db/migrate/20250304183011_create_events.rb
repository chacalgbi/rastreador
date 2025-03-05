class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :car_id
      t.string :car_name
      t.string :driver_id
      t.string :driver_name
      t.string :event_type
      t.string :event_name
      t.text :message

      t.timestamps
    end
  end
end
