class CheckListsController < ApplicationController
  before_action :check_admin_user

  def index
    @check_lists = build_filtered_check_lists
    @check_lists = @check_lists.order(created_at: :desc)
                               .page(params[:page])
                               .per(50)
  end

  private

  def check_admin_user
    unless Current.user&.admin?
      redirect_to root_path, alert: "Você não tem acesso a essa página"
    end
  end

  def build_filtered_check_lists
    check_lists = CheckList.all

    # Filtro por nome do motorista
    if params[:driver_name].present?
      user_ids = User.where("LOWER(name) LIKE LOWER(?)", "%#{params[:driver_name].downcase}%").pluck(:id)
      check_lists = check_lists.where(user_id: user_ids.map(&:to_s))
    end

    # Filtro por nome do carro
    if params[:car_name].present?
      detail_ids = Detail.where("LOWER(device_name) LIKE LOWER(?)", "%#{params[:car_name].downcase}%").pluck(:device_id)
      check_lists = check_lists.where(detail_id: detail_ids)
    end

    # Filtro por range de data
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      check_lists = check_lists.where('created_at >= ?', start_date)
    end

    if params[:end_date].present?
      end_date = Date.parse(params[:end_date]).end_of_day
      check_lists = check_lists.where('created_at <= ?', end_date)
    end

    # Filtro por observações preenchidas (indica problemas)
    if params[:with_observations] == 'true'
      check_lists = check_lists.where.not(obs: [nil, ''])
    end

    check_lists
  end

  def filter_params
    params.permit(:driver_name, :car_name, :start_date, :end_date, :with_observations, :page)
  end
end
