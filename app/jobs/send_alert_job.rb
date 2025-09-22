class SendAlertJob < ApplicationJob
  queue_as :alerts

  def perform(params)
    begin
      return false if params.nil? || params.empty?
      arg = params.symbolize_keys!
      return false if arg[:message].nil? || arg[:message].empty?

      @device_id = arg[:device_id]
      @phone = []
      @email = []
      @telegram = []
      @message = arg[:message]
      @evento = arg[:event]

      ENV["TYPE_APP"] == 'company' ? define_company_notifications : define_personal_notifications

      save_log(arg)

      send_telegram if arg[:alert_telegram]
      send_whatsapp if arg[:alert_whatsApp]
      send_email    if arg[:alert_email]

      true
    rescue StandardError => e
      error_message = "SendAlertJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error', error_message).save
      nil
    end

  end

  private

  def define_personal_notifications
    users = User.all.select do |user|
      next if user.cars.blank?
      user.cars.split(',').map(&:strip).include?(@device_id.to_s)
    end
    user_ids = users.map(&:id)

    Notification.where(user_id: user_ids.map(&:to_s)).find_each do |notification|
      @phone << notification.whatsapp if notification.whatsapp.present?
      @email << notification.email if notification.email.present?
      @telegram << notification.telegram if notification.telegram.present?
    end
  end

  def define_company_notifications
    Notification.find_each do |notification|
      @phone << notification.whatsapp if notification.whatsapp.present?
      @email << notification.email if notification.email.present?
      @telegram << notification.telegram if notification.telegram.present?
    end
  end

  def send_whatsapp
    unless @phone.nil? || @phone.empty?
      @phone.each do |cel|
        Notify.whatsapp(cel, @message)
      end
    end
  end

  def send_telegram
    unless @telegram.nil? || @telegram.empty?
      @telegram.each do |chat|
        Notify.telegram(chat, @message)
      end
    end
  end

  def send_email
    unless @email.nil? || @email.empty?
      @email.each do |email|
        # Notify.email(email, "Alerta(#{arg[:event]})", arg[:message]) # Não usando na versão atual
        NotifyMailer.notify(email, "Alerta(#{@evento})", @message).deliver_later
      end
    end
  end

  def save_log(args)
      msg_log = args[:message].gsub(/[\r\n]+/, " ")
      msg = "WhatsApp: (#{args[:alert_whatsApp]} #{@phone}), Telegram: (#{args[:alert_telegram]} #{@telegram}), Email: (#{args[:alert_email]} #{@email}) | #{msg_log}"
      SaveLog.new('alert_job', msg).save
  end
end
