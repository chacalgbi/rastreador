class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  validates :phone, presence: true, uniqueness: true

  generates_token_for :password_reset, expires_in: 24.hours

  def reset_password!
    self.password_reset_sent_at = nil
    save!
  end
end
