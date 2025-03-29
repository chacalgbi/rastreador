class Command < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["id", "type_device", "created_at", "name", "command", "description", "updated_at"]
  end
end
