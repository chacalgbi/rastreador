class SendAlertJob < ApplicationJob
  queue_as :default

  def perform(params)
    begin
      return false if params.nil? || params.empty?
      arg = params.symbolize_keys!
      return false if arg[:message].nil? || arg[:message].empty?
      msg_log = arg[:message].gsub(/[\r\n]+/, " ")

      msg = "Zap: #{arg[:alert_whatsApp]}, Telegram: #{arg[:alert_telegram]}, Email: #{arg[:alert_email]} | #{msg_log}"
      SaveLog.new('alert_job', msg).save

      if arg[:alert_whatsApp]
        # Implement WhatsApp notification logic here
      end

      if arg[:alert_telegram]
        unless arg[:telegram].nil? || arg[:telegram].empty?
          chats = arg[:telegram].split(',')
          chats.each do |chat|
            Notify.telegram(chat, arg[:message])
          end
        end
      end

      if arg[:alert_email]
        unless arg[:email].nil? || arg[:email].empty?
          emails = arg[:email].split(',')
          emails.each do |email|
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
