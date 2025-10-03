class Admin::PushNotificationsController < Admin::BaseController
  before_action :set_push_notification, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token, only: [:subscribe]
  before_action :authenticate, except: [:subscribe]

  def index
    @search = PushNotification.all.ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @push_notifications = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @push_notification = PushNotification.new
  end

  def edit
  end

  def create
    @push_notification = PushNotification.new(push_notification_params)

    if @push_notification.save
      SendPushNotification.new(@push_notification.title, @push_notification.body, 'note').all
      redirect_to [:admin, @push_notification], notice: "Push notification was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @push_notification.update(push_notification_params)
      redirect_to [:admin, @push_notification], notice: "Push notification was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @push_notification.destroy!
    redirect_to admin_push_notifications_url, notice: "Push notification was successfully destroyed."
  end

  def subscribe
    existing_subscription = PushSubscription.find_by(endpoint: params[:endpoint])

    device_info = {
      browser: params[:browser],
      device_type: params[:device_type],
      operating_system: params[:operating_system],
      user_agent: params[:user_agent],
      timezone: params[:timezone],
      language: params[:language],
      screen_resolution: params[:screen_resolution],
      timestamp: params[:timestamp]
    }.compact.to_json

    if existing_subscription
      update_params = {
        subscribed: true,
        info: device_info
      }
      update_params[:user_id] = params[:user_id] if params[:user_id].present?

      if existing_subscription.update(update_params)
        render json: { message: "Subscription already exists and updated" }, status: :ok
      else
        render json: { error: "Error updating existing subscription" }, status: :unprocessable_entity
      end
    else
      subscription = PushSubscription.new(
        endpoint: params[:endpoint],
        p256dh: params[:p256dh],
        auth: params[:auth],
        user_id: params[:user_id],
        subscribed: true,
        info: device_info
      )

      if subscription.save
        render json: { message: "Subscription successfully saved" }, status: :ok
      else
        render json: { error: "Error in storing subscription" }, status: :unprocessable_entity
      end
    end
  end

  private
  def set_push_notification
    @push_notification = PushNotification.find(params[:id])
  end

  def push_notification_params
    params.require(:push_notification).permit(:id, :title, :body, :created_at, :updated_at)
  end
end
