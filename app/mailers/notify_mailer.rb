class NotifyMailer < ApplicationMailer
  default from: "#{ENV['APPLICATION_NAME']} <#{ENV['SMTP_EMAIL']}>"
  self.delivery_job = NotifyMailDeliveryJob

  def notify(email, title, body)
    @body = body
    mail(to: email, subject: title)
  end
end
