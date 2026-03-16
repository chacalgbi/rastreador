class DetailsController < ApplicationController
  before_action :check_main_user
  before_action :set_detail, only: [:edit_settings, :update_settings]
  before_action :view_only_user?, only: [:update_settings]

  def index
    if Current.user&.pessoal
      car_ids = (Current.user.cars || "").split(",").map(&:strip).reject(&:blank?)
      scope = Detail.where(device_id: car_ids)
    elsif Current.user&.admin
      scope = Detail.all
    else
      scope = Detail.none
    end

    if params[:search].present?
      @details = scope.where("device_name LIKE ?", "%#{params[:search]}%")
    else
      @details = scope.order(:device_name, :device_id)
    end
  end

  def edit_settings
  end

  def update_settings
    if @detail.update(settings_params)
      create_event(@detail)
      redirect_to details_path, notice: "Veículo '#{@detail.device_name || @detail.device_id}' atualizado com sucesso!"
    else
      render :edit_settings, status: :unprocessable_entity
    end
  end

  private

  def set_detail
    @detail = Detail.find(params[:id])
  end

  def settings_params
    params.require(:detail).permit(
      :alert_whatsApp,
      :alert_telegram,
      :alert_email,
      :alert_push,
      :send_exit_cerca,
      :send_battery,
      :send_velo_max,
      :send_rele,
      :send_moving
    )
  end

  def check_main_user
    unless Current.user&.admin || Current.user&.pessoal
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end

  def create_event(detail)
    Event.create(
      car_id: detail.device_id,
      car_name: detail.device_name,
      driver_name: detail.last_user,
      event_type: 'commandSend',
      event_name: 'Update Alerts',
      message: "Canais(WhatsApp:#{true_or_false(detail.alert_whatsApp)} Telegram:#{true_or_false(detail.alert_telegram)} Email:#{true_or_false(detail.alert_email)} Push:#{true_or_false(detail.alert_push)})\n\nAlertas(Cerca:#{true_or_false(detail.send_exit_cerca)} Alarmes:#{true_or_false(detail.send_battery)} Velo. Máx:#{true_or_false(detail.send_velo_max)} Relé:#{true_or_false(detail.send_rele)} Movimento:#{true_or_false(detail.send_moving)})"
    )
  end

  def true_or_false(value)
    ActiveModel::Type::Boolean.new.cast(value) ? "🟢" : "🔴"
  end
end
