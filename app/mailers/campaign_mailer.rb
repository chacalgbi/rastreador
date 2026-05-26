class CampaignMailer < ApplicationMailer
  default from: "#{ENV['APPLICATION_NAME']} <#{ENV['SMTP_EMAIL']}>"

  def send_campaign(recipient_email, campaign_id)
    @campaign = EmailCampaign.find(campaign_id)
    mail(to: recipient_email, subject: @campaign.subject)
  end
end
