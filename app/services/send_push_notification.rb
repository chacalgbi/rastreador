class SendPushNotification
  def initialize(push_notification)
    @push_notification = push_notification
  end

  def all
    begin
      subscriptions = active_push_subscriptions
      return if subscriptions.empty?
      message = build_push_message
      vapid_details = build_vapid_details

      subscriptions.each do |subscription|
        next unless subscription.subscribed

        begin
          Rails.logger.info("Enviando push notification para a subscription #{subscription.id}")
          send_web_push_notification(message, subscription, vapid_details)
        rescue StandardError => e
          msg = "Erro ao enviar push notification para a subscription #{subscription.id}: #{e.message}\nBacktrace:\n#{e.backtrace.first(3).join("\n")}\n"
          Rails.logger.error(msg)
          SaveLog.new('push_notification_error', msg).save
          next
        end
      end
      true
    rescue StandardError => e
      msg = "Erro Geral no processo de push notification: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}\n"
      Rails.logger.error(msg)
      SaveLog.new('push_notification_error', msg).save
      false
    end
  end

  private

  def active_push_subscriptions
    PushSubscription.where(subscribed: true)
  end

  def build_push_message
    {
      title: @push_notification.title,
      body: @push_notification.body,
      icon: push_notification_icon_url
    }
  end

  def push_notification_icon_url
    ActionController::Base.helpers.image_url("note.png")
  end

  def build_vapid_details
    {
      subject: "mailto:#{ENV['DEFAULT_EMAIL']}",
      public_key: ENV["DEFAULT_APPLICATION_SERVER_KEY"],
      private_key: ENV["DEFAULT_PRIVATE_KEY"]
    }
  end

  def send_web_push_notification(message, subscription, vapid_details)
    WebPush.payload_send(
      message: JSON.generate(message),
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      vapid: vapid_details
    )
  end
end
