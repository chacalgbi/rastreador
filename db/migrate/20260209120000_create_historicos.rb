class CreateHistoricos < ActiveRecord::Migration[8.0]
  def change
    create_table :historicos do |t|
      t.string :device_id, null: false
      t.string :tipo, null: false             # "semanal" ou "mensal"
      t.string :descricao                      # "Semana 1/2026" ou "Janeiro/2026"
      t.integer :numero, null: false           # semana (1-52) ou mês (1-12)
      t.integer :ano, null: false              # ano de referência
      t.decimal :odometro, precision: 10, scale: 2, default: 0   # km acumulados no período
      t.decimal :horimetro, precision: 10, scale: 2, default: 0  # minutos acumulados no período
      t.decimal :odometro_inicio, precision: 10, scale: 2, default: 0  # valor cumulativo do odômetro no início do período
      t.decimal :horimetro_inicio, precision: 10, scale: 2, default: 0 # valor cumulativo do horímetro (em minutos) no início do período
      t.text :observacao
      t.timestamps
    end

    add_index :historicos, [:device_id, :tipo, :numero, :ano], unique: true, name: 'idx_historicos_unique'
    add_index :historicos, :device_id
  end
end
