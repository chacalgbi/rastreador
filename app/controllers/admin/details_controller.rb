class Admin::DetailsController < Admin::BaseController
  before_action :set_detail, only: %i[ show edit update destroy ]

  def index
    @search = Detail.all.ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @details = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @detail = Detail.new
  end

  def edit
  end

  def create
    @detail = Detail.new(detail_params)

    if @detail.save
      redirect_to [:admin, @detail], notice: "Detail was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @detail.update(detail_params)
      redirect_to [:admin, @detail], notice: "Detail was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @detail.destroy!
    redirect_to admin_details_url, notice: "Detail was successfully destroyed."
  end

  private
    def set_detail
      @detail = Detail.find(params[:id])
    end

    def detail_params
      params.require(:detail).permit(:device_id, :device_name, :model, :ignition, :rele_state, :url, :velo_max, :battery, :bat_bck, :horimetro, :odometro, :cercas, :satelites, :version, :imei, :bat_nivel, :signal_gps, :signal_gsm, :acc, :acc_virtual, :charge, :heartbeat, :obs, :status, :network, :params, :last_event_type, :apn, :ip_and_port, :alert_whatsApp, :alert_telegram, :alert_email, :send_exit_cerca, :send_battery, :send_velo_max, :send_rele, :created_at, :updated_at)
    end
end
