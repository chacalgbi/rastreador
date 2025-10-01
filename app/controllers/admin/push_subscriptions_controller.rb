class Admin::PushSubscriptionsController < Admin::BaseController
  before_action :set_push_subscription, only: %i[ show edit update destroy ]

  def index
    @search = PushSubscription.includes(:user).ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @push_subscriptions = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @push_subscription = PushSubscription.new
  end

  def edit
  end

  def create
    @push_subscription = PushSubscription.new(push_subscription_params)

    if @push_subscription.save
      redirect_to [:admin, @push_subscription], notice: "Push subscription was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @push_subscription.update(push_subscription_params)
      redirect_to [:admin, @push_subscription], notice: "Push subscription was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @push_subscription.destroy!
    redirect_to admin_push_subscriptions_url, notice: "Push subscription was successfully destroyed."
  end

  private
    def set_push_subscription
      @push_subscription = PushSubscription.find(params[:id])
    end

    def push_subscription_params
      params.require(:push_subscription).permit(:id, :endpoint, :p256dh, :auth, :user_id, :subscribed, :created_at, :updated_at)
    end
end
