class AddFieldCategoryToDetail < ActiveRecord::Migration[8.0]
  def change
    add_column :details, :category, :string
  end
end
