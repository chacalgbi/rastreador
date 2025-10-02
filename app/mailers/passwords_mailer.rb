class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset sua senha", to: user.email_address
  end
end
