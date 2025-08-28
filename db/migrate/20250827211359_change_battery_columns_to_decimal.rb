class ChangeBatteryColumnsToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :batteries, :bat, :decimal, precision: 5, scale: 2
    change_column :batteries, :bkp, :decimal, precision: 5, scale: 2
  end
end
