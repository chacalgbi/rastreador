class AddFieldSendMoving < ActiveRecord::Migration[8.0]
  def change
    add_column :details, :send_moving, :boolean, default: false
  end
end
