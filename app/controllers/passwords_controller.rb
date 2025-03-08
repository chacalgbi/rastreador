class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      random_string = SecureRandom.alphanumeric(6)
      titulo = "Redefinição de senha"
      corpo = "Sua nova senha é:\n\n#{random_string}\n\nPor favor, faça login e altere sua senha."

      response = Notify.email(params[:email_address], titulo, corpo)

      if response["erroGeral"] == "nao"
        user.password = random_string
        user.save
        redirect_to new_session_path, notice: "Instruções de redefinição de senha enviadas para o email: #{params[:email_address]}."
      else
        redirect_to new_session_path, alert: "Erro ao enviar mensagem para o email: #{params[:email_address]}. ERROR: #{response["msg"]}"
      end
    else
      redirect_to new_session_path, alert: "Email não encontrado: #{params[:email_address]}"
    end
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: "A senha foi redefinida."
    else
      redirect_to edit_password_path(params[:token]), alert: "As senhas não correspondem."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "O link de redefinição de senha é inválido ou expirou."
    end
end
