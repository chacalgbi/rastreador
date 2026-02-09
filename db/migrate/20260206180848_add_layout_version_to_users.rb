class AddLayoutVersionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :layout_version, :string, default: 'v1', null: false
  end
end
