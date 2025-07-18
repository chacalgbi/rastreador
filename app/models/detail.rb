class Detail < ApplicationRecord
  before_validation :set_default_values

  def self.ransackable_associations(auth_object = nil)
    %w[device_id device_name model ignition rele_state url velo_max battery bat_bck horimetro odometro cercas satelites version imei bat_nivel signal_gps signal_gsm acc acc_virtual charge heartbeat obs status network params last_event_type last_user apn ip_and_port alert_whatsApp alert_telegram alert_email send_exit_cerca send_battery send_moving send_velo_max send_rele created_at updated_at]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["acc", "acc_virtual", "alert_email", "alert_telegram", "alert_whatsApp", "apn", "bat_bck", "bat_nivel", "battery", "cercas", "charge", "created_at", "device_id", "device_name", "heartbeat", "horimetro", "id", "id_value", "ignition", "imei", "ip_and_port", "last_event_type", "last_rele_modified", "last_user", "model", "network", "obs", "odometro", "params", "rele_state", "satelites", "send_battery", "send_moving", "send_exit_cerca", "send_rele", "send_velo_max", "signal_gps", "signal_gsm", "status", "updated_at", "url", "velo_max", "version"]
  end

  private

def set_default_values
  # Rails.logger.debug ">>> Executando set_default_values para Detail #{id}"

  self.model = "xt40" if model.blank?
  self.ignition = "off" if ignition.blank?
  self.rele_state = "off" if rele_state.blank?
  self.status = "online" if status.blank?
  # self.last_user = "System" if last_user.blank?
end
end
