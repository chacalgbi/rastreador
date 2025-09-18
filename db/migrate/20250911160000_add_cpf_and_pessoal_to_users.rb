class AddCpfAndPessoalToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :cpf, :string
    add_column :users, :pessoal, :boolean, default: false, null: false
  end
end
