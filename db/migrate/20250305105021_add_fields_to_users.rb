class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :phone, :string, null: false
    add_column :users, :active, :boolean, default: false, null: false
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :cars, :text
  end
end
