class DriverController < ApplicationController
  before_action :check_main_user

  def index
    @drivers = User.all
  end

  def edit
    @user = User.find_by(id: params[:id])

    if @user.nil?
      redirect_to driver_index_path, alert: "Motorista não encontrado"
    end
  end

  def update
    @user = User.find_by(id: params[:id])

    if @user.update(params.require(:user).permit(:name, :email_address, :phone, :active, :admin))
      redirect_to driver_index_path, notice: "Motorista atualizado com sucesso."
    else
      error_message = @user.errors.full_messages.join(", ")
      redirect_to driver_index_path, alert: "Erro ao atualizar motorista: #{error_message}"
    end
  end

  def destroy
    @user = User.find_by(id: params[:id])

    if @user.id == Current.user.id
      redirect_to driver_index_path, alert: "Você não pode apagar a si mesmo."
    elsif @user.destroy
      redirect_to driver_index_path, notice: "Usuário apagado com sucesso."
    else
      error_message = @user.errors.full_messages.join(", ")
      redirect_to driver_index_path, alert: "Erro ao apagar usuário: #{error_message}"
    end
  end

  def cars
    user = User.find_by(id: params[:id])

    @array_devices = user&.cars.present? ? user.cars.split(",") : []
    @driver_id = params[:id]
    @driver_name = params[:name]
    @devices = Traccar.get_devices
    redirect_to driver_index_path, alert: "Veículos não encontrados" if @devices.empty?
  end

  def cars_update
    device_ids = params[:device_ids] || []
    user = User.find_by(id: params[:driver_id])
    redirect_to driver_index_path, alert: "Motorista não encontrado" if user.nil?

    device_ids_string = device_ids.join(",")
    user.update(cars: device_ids_string)

    msg = "O motorista #{params[:driver_name]} agora tem acesso a #{device_ids.count} veículos."
    redirect_to driver_index_path, notice: msg
  end

  private

  def check_main_user
    unless Current.user&.admin
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end
end
