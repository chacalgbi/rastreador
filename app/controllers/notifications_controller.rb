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

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def notification_params
    params.require(:notification).permit(:whatsapp, :email, :telegram)
  end

  def check_main_or_pessoal_user
    unless Current.user&.admin || Current.user&.pessoal
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end
end
