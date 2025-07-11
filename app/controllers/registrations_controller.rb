class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    @user.phone = @user.phone.gsub(/\D/, '') if @user.phone.present?

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: 'Usuário inscrito com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :name, :phone)
  end
end
