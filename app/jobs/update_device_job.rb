class UpdateDeviceJob < ApplicationJob
  queue_as :update_device

  def perform(params)
    begin
      Rails.logger.info("\nUpdateDeviceJob.perform - params: #{params.inspect}")
      return false if params.blank?
      args = params.symbolize_keys
      device_id = args[:device_id]
      return false if device_id.blank?
      detail = Detail.find_by(device_id: device_id)
      return false if detail.nil?

      Traccar.update_device(detail)
    rescue StandardError => e
      error_message = "UpdateDeviceJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error', error_message).save
      nil
    end
  end
end
