class NotifyMailDeliveryJob < ActionMailer::MailDeliveryJob
  ZOHO_TEMP_BLOCK_CODE = "550 5.4.6".freeze
  ZOHO_TEMP_BLOCK_TEXT = "Unusual sending activity detected".freeze
  MAX_ZOHO_RETRIES = 3

  rescue_from(Net::SMTPFatalError) do |error|
    if zoho_temporary_block?(error) && executions <= MAX_ZOHO_RETRIES
      message = "NotifyMailer TEMP_BLOCK | Zoho bloqueou temporariamente (tentativa #{executions}/#{MAX_ZOHO_RETRIES}). Reenfileirando em 10 minutos. Erro: #{error.message}"
      Rails.logger.warn(message)
      SaveLog.new("notify_temp_block", message).save if defined?(SaveLog)
      retry_job(wait: 10.minutes)
    else
      raise error
    end
  end

  private

  def zoho_temporary_block?(error)
    message = error.message.to_s
    message.include?(ZOHO_TEMP_BLOCK_CODE) && message.include?(ZOHO_TEMP_BLOCK_TEXT)
  end
end
