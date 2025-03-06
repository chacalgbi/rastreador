class DriverController < ApplicationController
  before_action :check_main_user

  def index
    #driver_index_path
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


  private

  def check_main_user
    unless Current.user&.admin
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end
end
