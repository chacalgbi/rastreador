class Notification < ApplicationRecord
  validates :user_id, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "id_value", "telegram", "updated_at", "user_id", "whatsapp"]
  end
end
