class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh, presence: true
  validates :auth, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "endpoint", "p256dh", "auth", "user_id", "created_at", "updated_at"]
  end
end
