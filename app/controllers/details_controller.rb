class DetailsController < ApplicationController
  before_action :check_main_user
  before_action :set_detail, only: [:edit_settings, :update_settings]

  def index
    if params[:search].present?
      @details = Detail.where("device_name LIKE ?", "%#{params[:search]}%")
    else
      @details = Detail.all.order(:device_name, :device_id)
    end
  end

  def edit_settings
  end

  def update_settings
    if @detail.update(settings_params)
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
      :send_exit_cerca,
      :send_battery,
      :send_velo_max,
      :send_rele,
      :send_moving
    )
  end

  def check_main_user
    unless Current.user&.admin
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end
end
