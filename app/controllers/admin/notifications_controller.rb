class Admin::NotificationsController < Admin::BaseController
  before_action :set_notification, only: %i[ show edit update destroy ]

  def index
    @search = Notification.includes(:user).ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @notifications = pagy(@search.result) }
      format.csv  { render csv: @search.result }
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

    if @notification.save
      redirect_to [:admin, @notification], notice: "Notification was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @notification.update(notification_params)
      redirect_to [:admin, @notification], notice: "Notification was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @notification.destroy!
    redirect_to admin_notifications_url, notice: "Notification was successfully destroyed."
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
      params.require(:notification).permit(:id, :user_id, :whatsapp, :email, :telegram, :sms, :created_at, :updated_at)
    end
end
