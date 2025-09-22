class SendCommandJob < ApplicationJob
  queue_as :status

  def perform(params)
    begin
      Rails.logger.info("\nSendCommandJob.perform - params: #{params.inspect}")
      return false if params.blank?
      args = params.symbolize_keys
      device_id = args[:device_id]
      command   = args[:command]
      return false if device_id.blank? || command.blank?

      Traccar.command(device_id, command)
    rescue StandardError => e
      error_message = "SendCommandJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error', error_message).save
      nil
    end
  end
end
