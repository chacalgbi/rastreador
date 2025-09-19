class ChangeEmailAddressIndexToAllowNulls < ActiveRecord::Migration[8.0]
  def up
    # Remove o índice atual
    remove_index :users, :email_address

    # Atualiza strings vazias para NULL primeiro
    execute "UPDATE users SET email_address = NULL WHERE email_address = ''"

    # Cria um novo índice que ignora valores NULL/vazios
    add_index :users, :email_address, unique: true, where: "email_address IS NOT NULL AND email_address != ''"
  end

  def down
    remove_index :users, :email_address
    add_index :users, :email_address, unique: true
  end
end
