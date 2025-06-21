class NotificationCacheService
  GLOBAL_TELEGRAM = []
  GLOBAL_WHATSAPP = []
  GLOBAL_EMAIL = []

  class << self
    def load_notifications
      clear_cache

      Notification.find_each do |notification|
        GLOBAL_TELEGRAM << notification.telegram if notification.telegram.present?
        GLOBAL_WHATSAPP << notification.whatsapp if notification.whatsapp.present?
        GLOBAL_EMAIL << notification.email if notification.email.present?
      end

      Rails.logger.info "Notificações carregadas: #{GLOBAL_TELEGRAM.size} Telegram, #{GLOBAL_WHATSAPP.size} WhatsApp, #{GLOBAL_EMAIL.size} Email"
    end

    def telegram_ids
      GLOBAL_TELEGRAM.dup
    end

    def whatsapp_numbers
      GLOBAL_WHATSAPP.dup
    end

    def email_addresses
      GLOBAL_EMAIL.dup
    end

    private

    def clear_cache
      GLOBAL_TELEGRAM.clear
      GLOBAL_WHATSAPP.clear
      GLOBAL_EMAIL.clear
    end
  end
end
