class Admin::HistoricosController < Admin::BaseController
  before_action :set_historico, only: %i[show edit update destroy]

  def index
    @search = Historico.all.ransack(params[:q])
    @search.sorts = 'updated_at desc' if @search.sorts.empty?

    respond_to do |format|
      format.html { @pagy, @historicos = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @historico = Historico.new
  end

  def edit
  end

  def create
    @historico = Historico.new(historico_params)

    if @historico.save
      redirect_to [:admin, @historico], notice: "Histórico criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @historico.update(historico_params)
      redirect_to [:admin, @historico], notice: "Histórico atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @historico.destroy!
    redirect_to admin_historicos_url, notice: "Histórico deletado com sucesso."
  end

  def destroy_old_historicos
    if params[:delete_before_date].present?
      delete_before_date = params[:delete_before_date].to_datetime
      deleted_count = Historico.where("updated_at < ?", delete_before_date).delete_all

      redirect_to admin_historicos_url, notice: "#{deleted_count} registro(s) de histórico foram deletados com sucesso."
    else
      redirect_to admin_historicos_url, alert: "Por favor, selecione uma data válida."
    end
  rescue ArgumentError
    redirect_to admin_historicos_url, alert: "Data inválida. Por favor, selecione uma data válida."
  end

  private

  def set_historico
    @historico = Historico.find(params[:id])
  end

  def historico_params
    params.require(:historico).permit(:device_id, :tipo, :descricao, :numero, :ano, :odometro, :horimetro, :odometro_inicio, :horimetro_inicio, :observacao)
  end
end
