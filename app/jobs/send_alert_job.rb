class SendAlertJob < ApplicationJob
  queue_as :default

  def perform(params)
    begin
      return false if params.nil? || params.empty?
      arg = params.symbolize_keys!
      return false if arg[:message].nil? || arg[:message].empty?
      msg_log = arg[:message].gsub(/[\r\n]+/, " ")

      msg = "WhatsApp: (#{arg[:alert_whatsApp]} #{arg[:phone]}), Telegram: (#{arg[:alert_telegram]} #{arg[:telegram]}), Email: (#{arg[:alert_email]} #{arg[:email]}) | #{msg_log}"
      SaveLog.new('alert_job', msg).save

      if arg[:alert_whatsApp]
        unless arg[:phone].nil? || arg[:phone].empty?
          arg[:phone].each do |cel|
            Notify.whatsapp(cel, arg[:message])
          end
        end
      end

      if arg[:alert_telegram]
        unless arg[:telegram].nil? || arg[:telegram].empty?
          arg[:telegram].each do |chat|
            Notify.telegram(chat, arg[:message])
          end
        end
      end

      if arg[:alert_email]
        unless arg[:email].nil? || arg[:email].empty?
          arg[:email].each do |email|
            # Notify.email(email, "Alerta(#{arg[:event]})", arg[:message]) # Não usando na versão atual
            NotifyMailer.notify(email, "Alerta(#{arg[:event]})", arg[:message]).deliver_later
          end
        end
      end

      true
    rescue StandardError => e
      error_message = "SendAlertJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error', error_message).save
      nil
    end

  end
end
