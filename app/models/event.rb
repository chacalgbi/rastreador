class Event < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["car_id", "car_name", "created_at", "driver_id", "driver_name", "event_name", "event_type", "id", "id_value", "message", "updated_at"]
  end
end
