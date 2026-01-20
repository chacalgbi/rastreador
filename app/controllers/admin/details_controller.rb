class Admin::DetailsController < Admin::BaseController
  before_action :set_detail, only: %i[ show edit update destroy ]

  def index
    @search = Detail.all.ransack(params[:q])
    @search.sorts = 'updated_at desc' if @search.sorts.empty?

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

  def rele
    send_command = define_send_command

    if params[:sms] == '0'
      response = Traccar.command(params[:device_id], send_command)
    elsif params[:sms] == '1'
      response = SendSms.send(params[:cell_number], send_command, params[:device_id], 'COMMAND')
    end

    if response != 200
      redirect_to admin_details_url, alert: "Erro ao enviar o comando: #{params[:state]}. Status da resposta: #{response}"
      return
    end

    notice = "O relé será #{params[:state] == 'ON' ? 'Ligado' : 'Desligado'}."
    redirect_to admin_details_url, notice: notice
  end

  def send_command
    send_command = SendCommand.new(params[:model], params[:device_id], params[:command], params[:imei])
    response = ''
    case params[:command]
    when 'zerar_hodometro'
      response_rastreador = send_command.reset_odometer
      response_traccar = Traccar.reset_odometro(params[:device_id])
      response = "Em breve o valor do hodômetro será atualizado! #{response_rastreador} | #{response_traccar}"
    when 'zerar_horimetro'
      response_rastreador = send_command.reset_hour_meter
      response_traccar = Traccar.reset_horimetro(params[:device_id])
      response = "Em breve o valor do horímetro será atualizado! #{response_rastreador} | #{response_traccar}"
    when 'parametros'
      response = send_command.params
    when 'get_iccid'
      response = send_command.get_iccid
    else
      response = "Comando desconhecido: #{params[:command]}"
    end

    redirect_to admin_details_url, notice: response
  end

  private
  def set_detail
    @detail = Detail.find(params[:id])
  end

  def detail_params
    params.require(:detail).permit(:device_id, :device_name, :last_user, :model, :ignition, :rele_state, :url, :velo_max, :battery, :bat_bck, :horimetro, :odometro, :cercas, :satelites, :version, :imei, :iccid, :bat_nivel, :signal_gps, :signal_gsm, :acc, :acc_virtual, :charge, :heartbeat, :obs, :status, :network, :params, :last_event_type, :apn, :ip_and_port, :alert_whatsApp, :alert_telegram, :alert_email, :send_exit_cerca, :send_battery, :send_moving, :send_velo_max, :send_rele, :created_at, :updated_at, :category, :cell_number)
  end

  def define_send_command
    command_name = params[:state] == 'ON' ? 'rele_on' : 'rele_off'
    command = Command.find_by(type_device: params[:model], name: command_name)

    return command.command_sms if params[:sms] == '1'
    return command.command if command.type_device == 'xt40'
    return command.command.gsub('XXXX', params[:imei]) if command.type_device == 'st8310u'
  end
end
