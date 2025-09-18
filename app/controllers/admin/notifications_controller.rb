class Admin::NotificationsController < Admin::BaseController
  before_action :set_notification, only: %i[ show edit update destroy ]

  def index
    @search = Notification.all.ransack(params[:q])

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

  private
    def set_notification
      @notification = Notification.find(params[:id])
    end

    def notification_params
      params.require(:notification).permit(:id, :user_id, :whatsapp, :email, :telegram, :created_at, :updated_at)
    end
end
