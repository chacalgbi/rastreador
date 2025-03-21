class NotifyMailer < ApplicationMailer
  default from: "envio@dealerta.com.br"

  def notify(email, title, body)
    @body = body
    mail(to: email, subject: title)
  end
end
