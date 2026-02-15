class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # details: coluna mais consultada em toda a aplicação (webhooks, home, etc.)
    add_index :details, :device_id, unique: true

    # events: consultas por car_id + created_at (query_events no HomeController)
    add_index :events, [:car_id, :created_at]
    add_index :events, :created_at

    # commands: consulta por type_device + name (TraccarUpdateDevice, HomeController)
    add_index :commands, [:type_device, :name]

    # batteries: consultas e inserções por device_id
    add_index :batteries, :device_id

    # notifications: consultas por user_id
    add_index :notifications, :user_id
  end
end
