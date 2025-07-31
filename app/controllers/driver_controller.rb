class DriverController < ApplicationController
  before_action :check_main_user

  def index
    @drivers = User.order(:name)
  end

  def new
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(:name, :phone, :password, :password_confirmation)
    user_params[:phone] = user_params[:phone].gsub(/\D/, "") if user_params[:phone].present?

    @user = User.new(user_params)

    if @user.save
      flash[:notice] = "Motorista cadastrado com sucesso."
      redirect_to driver_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash[:alert] = "Motorista não encontrado"
      redirect_to driver_index_path
    end
  end

  def update
    @user = User.find_by(id: params[:id])

    user_params = params.require(:user).permit(:name, :email_address, :phone, :active, :admin)
    user_params[:phone] = user_params[:phone].gsub(/\D/, "") if user_params[:phone].present?

    if @user.update(user_params)
      flash[:notice] = "Motorista atualizado com sucesso."
      redirect_to driver_index_path
    else
      error_message = @user.errors.full_messages.join(", ")
      flash[:alert] = "Erro ao atualizar motorista: #{error_message}"
      redirect_to driver_index_path
    end
  end

  def destroy
    @user = User.find_by(id: params[:id])

    if @user.id == Current.user.id
      flash[:alert] = "Você não pode apagar a si mesmo."
      redirect_to driver_index_path
    elsif @user.destroy
      flash[:notice] = "Usuário apagado com sucesso."
      redirect_to driver_index_path
    else
      error_message = @user.errors.full_messages.join(", ")
      flash[:alert] = "Erro ao apagar usuário: #{error_message}"
      redirect_to driver_index_path
    end
  end

  def cars
    user = User.find_by(id: params[:id])

    @array_devices = user&.cars.present? ? user.cars.split(",") : []
    @driver_id = params[:id]
    @driver_name = params[:name]
    @devices = Detail.all
    if @devices.empty?
      flash[:alert] = "Veículos não encontrados"
      redirect_to driver_index_path
    end
  end

  def cars_update
    device_ids = params[:device_ids] || []
    user = User.find_by(id: params[:driver_id])
    if user.nil?
      flash[:alert] = "Motorista não encontrado"
      redirect_to driver_index_path
      return
    end

    device_ids_string = device_ids.join(",")
    user.update(cars: device_ids_string)

    msg = "O motorista #{params[:driver_name]} agora tem acesso a #{device_ids.count} veículos."
    flash[:notice] = msg
    redirect_to driver_index_path
  end

  def edit_password
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash[:alert] = "Motorista não encontrado"
      redirect_to driver_index_path
    end
  end

  def update_password
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash[:alert] = "Motorista não encontrado"
      redirect_to driver_index_path
      return
    end

    password_params = params.require(:user).permit(:password, :password_confirmation)

    # Validação manual do comprimento da senha apenas se não estiver vazia
    if password_params[:password].present? && password_params[:password].length < 5
      @user.errors.add(:password, "deve ter pelo menos 5 caracteres")
      render :edit_password, status: :unprocessable_entity
      return
    end

    # O has_secure_password automaticamente valida a confirmação da senha
    if @user.update(password_params)
      flash[:notice] = "Senha do motorista #{@user.name} foi alterada com sucesso."
      redirect_to driver_index_path
    else
      render :edit_password, status: :unprocessable_entity
    end
  end

  # Ação temporária para testar flash messages
  def test_flash
    flash[:notice] = "Teste de mensagem de sucesso - Flash funcionando!"
    redirect_to driver_index_path
  end

  private

  def check_main_user
    unless Current.user&.admin
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end
end
