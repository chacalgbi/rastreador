class AddIccidToDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :details, :iccid, :string
  end
end
