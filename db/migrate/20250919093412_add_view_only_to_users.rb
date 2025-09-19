class AddViewOnlyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :view_only, :boolean, default: false
  end
end
