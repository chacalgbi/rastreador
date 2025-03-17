class Detail < ApplicationRecord
  def self.ransackable_associations(auth_object = nil)
    %w[device_id device_name model ignition rele_state url velo_max battery bat_bck horimetro odometro cercas satelites version imei bat_nivel signal_gps signal_gsm acc acc_virtual charge heartbeat obs status network params last_event_type apn ip_and_port alert_whatsApp alert_telegram alert_email send_exit_cerca send_battery send_velo_max send_rele created_at updated_at]
  end
end
