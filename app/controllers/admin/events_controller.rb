class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: %i[ show edit update destroy ]

  def index
    params[:q] ||= { s: 'created_at desc' }
    @search = Event.all.ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @events = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to [:admin, @event], notice: "Event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      redirect_to [:admin, @event], notice: "Event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to admin_events_url, notice: "Event was successfully destroyed."
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:id, :car_id, :car_name, :driver_id, :driver_name, :event_type, :event_name, :message, :created_at, :updated_at)
    end
end
