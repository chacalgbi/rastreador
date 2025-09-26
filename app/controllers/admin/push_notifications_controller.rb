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
      send_push_notification(@push_notification)
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

    if existing_subscription
      if existing_subscription.update(subscribed: true)
        render json: { message: "Subscription already exists and updated" }, status: :ok
      else
        render json: { error: "Error updating existing subscription" }, status: :unprocessable_entity
      end
    else
      # Se não existe, cria uma nova subscrição
      subscription = PushSubscription.new(
        endpoint: params[:endpoint],
        p256dh: params[:p256dh],
        auth: params[:auth],
        subscribed: true
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

  def send_push_notification(push_notification)
    subscriptions = active_push_subscriptions
    latest_subscription = subscriptions.last
    return unless latest_subscription

    message = build_push_message(push_notification)
    vapid_details = build_vapid_details
    send_web_push_notification(message, latest_subscription, vapid_details)
  end

  def active_push_subscriptions
    PushSubscription.where(subscribed: true)
  end

  def build_push_message(push_notification)
    {
      title: push_notification.title,
      body: push_notification.body,
      icon: push_notification_icon_url
    }
  end

  def push_notification_icon_url
    ActionController::Base.helpers.image_url("note.png")
  end

  def build_vapid_details
    {
      subject: "mailto:#{ENV['DEFAULT_EMAIL']}",
      public_key: ENV["DEFAULT_APPLICATION_SERVER_KEY"],
      private_key: ENV["DEFAULT_PRIVATE_KEY"]
    }
  end

  def send_web_push_notification(message, subscription, vapid_details)
    WebPush.payload_send(
      message: JSON.generate(message),
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      vapid: vapid_details
    )
  end
end
