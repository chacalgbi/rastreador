class AddSleepingToDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :details, :sleeping, :boolean, default: false
  end
end
