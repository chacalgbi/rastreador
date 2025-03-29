class CreateCommands < ActiveRecord::Migration[8.0]
  def change
    create_table :commands do |t|
      t.string :type
      t.string :name
      t.string :command
      t.text :description

      t.timestamps
    end
  end
end
