Rails.application.config.after_initialize do
  NotificationCacheService.load_notifications
end
