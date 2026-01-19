class Admin::CommandsController < Admin::BaseController
  before_action :set_command, only: %i[ show edit update destroy ]

  def index
    @search = Command.all.ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @commands = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @command = Command.new
  end

  def edit
  end

  def create
    @command = Command.new(command_params)

    if @command.save
      redirect_to [:admin, @command], notice: "Command was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @command.update(command_params)
      redirect_to [:admin, @command], notice: "Command was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @command.destroy!
    redirect_to admin_commands_url, notice: "Command was successfully destroyed."
  end

  def send_command
    comando = params[:comando]
    device_ids_param = params[:deviceid]

    if comando.blank?
      redirect_to admin_commands_path, alert: "Comando não pode estar vazio."
      return
    end

    if device_ids_param.blank?
      redirect_to admin_commands_path, alert: "Device ID não pode estar vazio."
      return
    end

    device_ids = device_ids_param.split(',').map(&:strip).reject(&:blank?)

    if device_ids.empty?
      redirect_to admin_commands_path, alert: "Nenhum Device ID válido fornecido."
      return
    end

    results = []

    device_ids.each do |device_id|
      begin
        response = Traccar.command(device_id, comando)
        results << "(#{device_id}, #{response})"
      rescue => e
        results << "(#{device_id}, ERRO: #{e.message})"
        SaveLog.new('error', "Erro ao enviar comando para device #{device_id}: #{e.message}").save
      end
    end

    if device_ids.size == 1
      message = "O comando '#{comando}' foi enviado para o veículo #{device_ids.first}: #{results.first}"
    else
      message = "O comando '#{comando}' foi enviado para #{device_ids.size} veículos: #{results.join(', ')}"
    end

    SaveLog.new('info', message).save
    redirect_to admin_commands_path, notice: message
  end

  def send_command_to_all
    comando = params[:comando]

    if comando.blank?
      redirect_to admin_commands_path, alert: "Comando não pode estar vazio."
      return
    end

    device_ids = Detail.pluck(:device_id)

    if device_ids.empty?
      redirect_to admin_commands_path, alert: "Nenhum veículo encontrado."
      return
    end

    results = []

    device_ids.each do |device_id|
      begin
        response = Traccar.command(device_id, comando)
        results << "(#{device_id}, #{response})"
      rescue => e
        results << "(#{device_id}, ERRO: #{e.message})"
        SaveLog.new('error', "Erro ao enviar comando para device #{device_id}: #{e.message}").save
      end
    end

    message = "Comando '#{comando}' enviado para todos os veículos: #{results.join(', ')}"
    SaveLog.new('info', message).save
    redirect_to admin_commands_path, notice: message
  end

  def send_command_sms
    comando = params[:comando]
    device_ids_param = params[:deviceid]

    if comando.blank?
      redirect_to admin_commands_path, alert: "Comando não pode estar vazio."
      return
    end

    if device_ids_param.blank?
      redirect_to admin_commands_path, alert: "Device ID não pode estar vazio."
      return
    end

    device_ids = device_ids_param.split(',').map(&:strip).reject(&:blank?)

    if device_ids.empty?
      redirect_to admin_commands_path, alert: "Nenhum Device ID válido fornecido."
      return
    end

    results = []

    device_ids.each do |device_id|
      begin
        @detail = Detail.find_by(device_id: device_id)
        cell_number = @detail&.cell_number
        if cell_number.blank?
          results << "(#{device_id}, ERRO: Número de celular não encontrado)"
          next
        end
        response = SendSms.send(cell_number, comando, device_id, 'COMMAND')
        results << "(#{device_id}, #{response})"
      rescue => e
        results << "(#{device_id}, ERRO: #{e.message})"
        SaveLog.new('error', "Erro ao enviar sms para device #{device_id}: #{e.message}").save
      end
    end

    if device_ids.size == 1
      message = "O sms '#{comando}' foi enviado para o veículo #{device_ids.first}: #{results.first}"
    else
      message = "O sms '#{comando}' foi enviado para #{device_ids.size} veículos: #{results.join(', ')}"
    end

    SaveLog.new('enviar_sms', message).save
    redirect_to admin_commands_path, notice: message
  end

  private
  def set_command
    @command = Command.find(params[:id])
  end

  def command_params
    params.require(:command).permit(:id, :type_device, :name, :command, :command_sms, :description, :created_at, :updated_at)
  end
end
