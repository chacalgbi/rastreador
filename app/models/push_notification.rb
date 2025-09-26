class PushNotification < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "body", "created_at", "updated_at"]
  end
end
