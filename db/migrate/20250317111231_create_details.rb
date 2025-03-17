class CreateDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :details do |t|
      t.string :device_id
      t.string :device_name
      t.string :model
      t.string :ignition
      t.string :rele_state
      t.string :last_event_type
      t.string :last_user
      t.datetime :last_rele_modified
      t.string :url
      t.string :velo_max
      t.string :battery
      t.string :bat_bck
      t.string :horimetro
      t.string :odometro
      t.string :cercas
      t.string :satelites
      t.string :version
      t.string :imei
      t.string :bat_nivel
      t.string :signal_gps
      t.string :signal_gsm
      t.string :acc
      t.string :acc_virtual
      t.string :charge
      t.string :heartbeat
      t.text :obs
      t.text :status
      t.text :network
      t.text :params
      t.string :apn
      t.string :ip_and_port
      t.boolean :alert_whatsApp, default: false
      t.boolean :alert_telegram, default: false
      t.boolean :alert_email, default: false
      t.boolean :send_exit_cerca, default: false
      t.boolean :send_battery, default: false
      t.boolean :send_velo_max, default: false
      t.boolean :send_rele, default: false

      t.timestamps
    end
  end
end
