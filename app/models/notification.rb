class Notification < ApplicationRecord
  after_commit :reload_notification_cache

  private

  def reload_notification_cache
    NotificationCacheService.load_notifications
  end
end
