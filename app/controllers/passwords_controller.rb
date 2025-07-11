class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    clean_phone = params[:phone].gsub(/\D/, '') if params[:phone].present?

    if user = User.find_by(phone: clean_phone)
      user.update!(password_reset_sent_at: Time.current)
      token = user.generate_token_for(:password_reset)

      Rails.logger.info "DEBUG: Token gerado: #{token}"
      Rails.logger.info "DEBUG: URL gerada: #{edit_password_url(token: token)}"

      corpo = "Acesse o link para trocar a senha: #{edit_password_url(token: token)}"

      response = Notify.whatsapp(clean_phone, corpo)

      if response["erroGeral"] == "nao"
        redirect_to new_session_path, notice: "Instruções de redefinição de senha enviadas para o telefone: #{clean_phone}."
      else
        redirect_to new_session_path, alert: "Erro ao enviar mensagem para o telefone: #{clean_phone}. ERROR: #{response["msg"]}"
      end
    else
      redirect_to new_session_path, alert: "Telefone não encontrado: #{params[:phone]}"
    end
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.reset_password!
      redirect_to new_session_path, notice: "A senha foi redefinida com sucesso."
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_user_by_token
    Rails.logger.info "DEBUG: Token recebido da URL: #{params[:token]}"
    @user = User.find_by_token_for(:password_reset, params[:token])
    Rails.logger.info "DEBUG: Usuário encontrado: #{@user.present?}"

    unless @user
      redirect_to new_password_path, alert: "O link de redefinição de senha é inválido ou expirou."
    end
  end
end
