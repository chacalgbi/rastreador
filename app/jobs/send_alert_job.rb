class SendAlertJob < ApplicationJob
  queue_as :default

  def perform(params)
    return false if params.nil? || params.empty?

    arg = params.symbolize_keys!

    return false if arg[:message].nil? || arg[:message].empty?

    if arg[:alert_whatsApp]
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

  end
end
