class CreateCheckLists < ActiveRecord::Migration[8.0]
  def change
    create_table :check_lists do |t|
      t.string :user_id
      t.string :detail_id
      t.string :type
      t.boolean :freios, default: false
      t.boolean :luzes, default: false
      t.boolean :pneus, default: false
      t.boolean :estepe, default: false
      t.boolean :oleo, default: false
      t.boolean :buzina, default: false
      t.boolean :painel, default: false
      t.boolean :doc, default: false
      t.boolean :retrovisor, default: false
      t.boolean :parabrisa, default: false
      t.boolean :limpador, default: false
      t.boolean :macaco, default: false
      t.boolean :lataria, default: false
      t.text :obs

      t.timestamps
    end
  end
end
