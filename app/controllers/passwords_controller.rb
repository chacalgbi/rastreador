class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    login = params[:phone]
    isphone = false
    msg = ""
    clean_phone = nil
    user = nil

    if login.present?
      if login.include?("@")
        user = User.find_by(email_address: login)
      else
        clean_phone = login.gsub(/\D/, '')
        isphone = true
        user = User.find_by(phone: clean_phone)
      end
    end

    if user
      user.update!(password_reset_sent_at: Time.current)
      token = user.generate_token_for(:password_reset)
      url = edit_password_url(token: token)
      corpo = "Acesse o link para trocar a senha: #{url}"
      msg_log = "Login: #{login} - Usuário: #{user.name} - Solicitou alteração de senha.\nToken gerado: #{token}\nURL gerada: #{url}"

      SaveLog.new('redefinir_senha', msg_log).save

      if isphone
        Notify.whatsapp(clean_phone, corpo)
        msg = "Instruções de redefinição de senha enviadas para o telefone: #{clean_phone}."
      else
        NotifyMailer.notify(user.email_address, "Redefinição de senha", corpo).deliver_later
        msg = "Instruções de redefinição de senha enviadas para o e-mail: #{user.email_address}."
      end

      redirect_to new_session_path, notice: msg
    else
      redirect_to new_session_path, alert: "Telefone ou e-mail não encontrado: #{params[:phone]}"
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
