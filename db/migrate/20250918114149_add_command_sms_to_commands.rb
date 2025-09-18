class AddCommandSmsToCommands < ActiveRecord::Migration[8.0]
  def change
    add_column :commands, :command_sms, :string
  end
end
