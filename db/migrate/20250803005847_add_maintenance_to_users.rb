class AddMaintenanceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :maintenance, :boolean, default: false
  end
end
