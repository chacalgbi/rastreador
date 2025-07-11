class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Tente novamente mais tarde." }

  def new
  end

  def create
    phone = params[:phone]
    password = params[:password]

    clean_phone = phone.gsub(/\D/, '') if phone.present?

    user = User.find_by(phone: clean_phone)&.authenticate(password)

    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Login feito com sucesso!"
    else
      redirect_to new_session_path, alert: "Telefone ou senha inválidos!"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
