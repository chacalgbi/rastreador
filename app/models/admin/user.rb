class Admin::User < Admin::ApplicationRecord
  has_secure_password

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 6 }

  normalizes :email, with: -> { _1.strip.downcase }

  def self.ransackable_attributes(auth_object = nil)
    %w[email cpf phone created_at]
  end
end
