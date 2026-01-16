class Admin::BatteriesController < Admin::BaseController
  before_action :set_battery, only: %i[ show edit update destroy ]

  def index
    @search = Battery.all.ransack(params[:q])
    @search.sorts = 'updated_at desc' if @search.sorts.empty?

    respond_to do |format|
      format.html { @pagy, @batteries = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @battery = Battery.new
  end

  def edit
  end

  def create
    @battery = Battery.new(battery_params)

    if @battery.save
      redirect_to [:admin, @battery], notice: "Battery was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @battery.update(battery_params)
      redirect_to [:admin, @battery], notice: "Battery was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @battery.destroy!
    redirect_to admin_batteries_url, notice: "Battery was successfully destroyed."
  end

  def destroy_old_batteries
    if params[:delete_before_date].present?
      delete_before_date = params[:delete_before_date].to_datetime
      deleted_count = Battery.where("updated_at < ?", delete_before_date).delete_all

      redirect_to admin_batteries_url, notice: "#{deleted_count} registro(s) de bateria foram deletados com sucesso."
    else
      redirect_to admin_batteries_url, alert: "Por favor, selecione uma data válida."
    end
  rescue ArgumentError
    redirect_to admin_batteries_url, alert: "Data inválida. Por favor, selecione uma data válida."
  end

  private
    def set_battery
      @battery = Battery.find(params[:id])
    end

    def battery_params
      params.require(:battery).permit(:device_id, :device_name, :user_id, :user_name, :bat, :bkp, :created_at, :updated_at)
    end
end
