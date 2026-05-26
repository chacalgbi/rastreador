class EmailCampaign < ApplicationRecord
  validates :subject, presence: true
  validates :recipients, presence: true
  validates :body_html, presence: true

  def parsed_recipients
    recipients.to_s
              .split(",")
              .map(&:strip)
              .reject(&:blank?)
              .select { |email| email.match?(URI::MailTo::EMAIL_REGEXP) }
              .uniq
  end
end
