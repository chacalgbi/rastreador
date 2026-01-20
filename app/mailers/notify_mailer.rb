class NotifyMailer < ApplicationMailer
  default from: "#{ENV['APPLICATION_NAME']} <#{ENV['EMAIL']}>"

  def notify(email, title, body)
    @body = body
    mail(to: email, subject: title)
  end
end
