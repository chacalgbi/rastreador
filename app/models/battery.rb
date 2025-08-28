class Battery < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["id", "device_id", "created_at", "device_name", "user_id", "user_name", "bat", "bkp", "updated_at"]
  end
end
