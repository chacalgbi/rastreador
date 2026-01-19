class NotificationsController < ApplicationController
  before_action :check_main_or_pessoal_user
  before_action :set_notification, only: %i[ show edit update destroy ]
  before_action :view_only_user?, only: [:create, :update, :destroy]

  def index
    if Current.user&.admin?
      @notifications = Notification.all
    elsif Current.user
      @notifications = Notification.where(user_id: Current.user.id.to_s)
    else
      @notifications = Notification.none
    end
  end

  def show
  end

  def new
    @notification = Notification.new
  end

  def edit
  end

  def create
    @notification = Notification.new(notification_params)
    @notification.user_id = Current.user&.id if Current.user

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification, notice: "Notificação criada com sucesso!" }
        format.json { render :show, status: :created, location: @notification }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: "Notificação atualizada com sucesso!" }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @notification.destroy!

    respond_to do |format|
      format.html { redirect_to notifications_path, status: :see_other, notice: "Notificação deletada com sucesso!" }
      format.json { head :no_content }
    end
  end

  def test_email
    email = params[:email]
    if email.present?
      result = Notify.email(email, "Teste de Email", "Esta é uma mensagem de teste do sistema de rastreamento.")

      if result && result["erroGeral"] == "nao"
        render json: { success: true, message: "Email de teste enviado com sucesso!", result: result }
      else
        error_msg = result && result["msg"] ? result["msg"] : "Erro ao enviar email"
        render json: { success: false, message: "Falha ao enviar email: #{error_msg}", result: result }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Por favor, informe um email válido." }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { success: false, message: "Erro ao enviar email: #{e.message}" }, status: :unprocessable_entity
  end

  def test_whatsapp
    whatsapp = params[:whatsapp]
    if whatsapp.present?
      result = Notify.whatsapp(whatsapp, "Teste de WhatsApp: Esta é uma mensagem de teste do sistema de rastreamento.")

      if result && result["erroGeral"] == "nao"
        render json: { success: true, message: "Mensagem de WhatsApp enviada com sucesso!", result: result }
      else
        error_msg = result && result["msg"] ? result["msg"] : "Erro ao enviar WhatsApp"
        render json: { success: false, message: "Falha ao enviar WhatsApp: #{error_msg}", result: result }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Por favor, informe um número de WhatsApp válido." }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { success: false, message: "Erro ao enviar WhatsApp: #{e.message}" }, status: :unprocessable_entity
  end

  def test_telegram
    telegram = params[:telegram]
    if telegram.present?
      result = Notify.telegram(telegram, "Teste de Telegram: Esta é uma mensagem de teste do sistema de rastreamento.")

      if result && result["ok"] == true
        render json: { success: true, message: "Mensagem de Telegram enviada com sucesso!", result: result }
      else
        error_msg = result && result["description"] ? result["description"] : "Erro ao enviar Telegram"
        render json: { success: false, message: "Falha ao enviar Telegram: #{error_msg}", result: result }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Por favor, informe um chat_id de Telegram válido." }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { success: false, message: "Erro ao enviar Telegram: #{e.message}" }, status: :unprocessable_entity
  end

  def test_sms
    sms = params[:sms]
    if sms.present?
      result = SendSms.send(sms, "Teste de SMS: Esta é uma mensagem de teste do sistema de rastreamento.", '1', 'GENERIC')

      if result && result["erroGeral"] == "nao"
        render json: { success: true, message: "Mensagem de SMS enviada com sucesso!", result: result }
      else
        error_msg = result && result["msg"] ? result["msg"] : "Erro ao enviar SMS"
        render json: { success: false, message: "Falha ao enviar SMS: #{error_msg}", result: result }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Por favor, informe um número de telefone válido." }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { success: false, message: "Erro ao enviar SMS: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def notification_params
    params.require(:notification).permit(:whatsapp, :email, :telegram, :sms)
  end

  def check_main_or_pessoal_user
    unless Current.user&.admin || Current.user&.pessoal
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end
end
