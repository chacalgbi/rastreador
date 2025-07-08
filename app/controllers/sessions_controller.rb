class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Tente novamente mais tarde." }

  def new
  end

  def create
    email_or_phone = params[:email_address]
    password = params[:password]

    user = User.authenticate_by(email_address: email_or_phone, password: password)

    if user.nil?
      user = User.find_by(phone: email_or_phone)&.authenticate(password)
    end

    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Login feito com sucesso!"
    else
      redirect_to new_session_path, alert: "Email/telefone ou senha inválidos!"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
