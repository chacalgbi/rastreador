class NotifyMailer < ApplicationMailer
  default from: "#{ENV['APPLICATION_NAME']} <#{ENV['SMTP_EMAIL']}>"

  def notify(email, title, body)
    @body = body
    mail(to: email, subject: title)
  end
end
