class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true, length: { minimum: 11 }
  validates :password, length: { minimum: 5 }, on: :create

  generates_token_for :password_reset, expires_in: 24.hours

  def self.ransackable_attributes(auth_object = nil)
    ["active", "admin", "cars", "cpf", "created_at", "email_address", "id", "id_value", "maintenance", "name", "password_reset_sent_at", "pessoal", "phone", "updated_at"]
  end

  def reset_password!
    self.password_reset_sent_at = nil
    save!
  end
end
