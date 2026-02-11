class HomeController < ApplicationController
  # event_type
  # ignitionOn ignitionOff deviceOffline deviceOnline deviceMoving deviceStopped geofenceExit geofenceEnter deviceOverspeed
  # alarm commandResult

  # event_name
  # 'rele' 'resposta' 'ligado' 'desligado' 'movendo' 'parado' 'cerca' 'velocidade' 'Off-Line' 'On-Line' 'lowBattery' 'powerCut'
  # 'sos' 'powerRestored' 'Acidente' 'hardAcceleration' 'jamming'

  IGNORED_EVENT_TYPES = ['deviceOffline', 'deviceOnline', 'ignitionOn', 'ignitionOff', 'deviceStopped', 'deviceMoving'].freeze
  IGNORED_EVENT_NAMES = ['resposta'].freeze
  HOURS_LAST_EVENTS = 96
  before_action :set_global_variables
  before_action :view_only_user?, only: [:block_and_desblock, :odometro]

  def set_global_variables
    @user_admin = Current.user.admin?
    @pessoal = Current.user&.pessoal?
    @layout_version = Current.user&.respond_to?(:layout_version) ? Current.user.layout_version : 'v1'
  end

  # Helper para resolver o path do partial conforme a versão do layout
  def resolve_partial(base_partial)
    if @layout_version == 'v2'
      # Tenta o caminho v2, ex: "home/details" => "home/v2/details"
      parts = base_partial.split('/')
      parts.insert(-2, 'v2') if parts.length >= 2
      v2_partial = parts.join('/')
      # Verifica se o partial v2 existe
      lookup_context.exists?(v2_partial, [], true) ? v2_partial : base_partial
    else
      base_partial
    end
  end
  helper_method :resolve_partial

  def toggle_layout
    new_version = Current.user.layout_version == 'v2' ? 'v1' : 'v2'
    Current.user.update(layout_version: new_version)
    redirect_to root_path
  end

  def index
    @devices = Current.user.admin? ? devices_admin : devices_user
    return render partial: resolve_partial("home/indexpartial"), locals: { devices: @devices } if turbo_frame_request?
    @search_query = params[:query].present?
    @devices = Kaminari.paginate_array(@devices).page(params[:page]).per(10)
  end

  def location
    @location_url = params[:url]

    if @location_url.empty?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Erro ao buscar a posição do veículo." }
          )
        end
        format.html { redirect_to root_path, alert: "Erro ao buscar a posição do veículo." }
      end
      return
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "location_#{params[:car_id]}",
          partial: "home/location",
          locals: { location_url: @location_url }
        )
      end
    end
  end

  def details
    device_id = params[:device_id]
    @event = Detail.find_by(device_id: device_id)
    @events_last_x_hours = query_events(device_id).count

    if @event.status == 'online'
      send_command('Status')
      send_command('network')
      send_command('parametros')
    end

    info = @event
    msg = define_text(@event, params[:status])
    state = define_state(@event)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: resolve_partial("home/details"), locals: {status: params[:status], info: info, msg: msg, device_id: device_id, state: state, events_count: @events_last_x_hours}),
          turbo_stream.replace("details_button_#{device_id}", partial: resolve_partial("home/details_button"), locals: { device_id: device_id, show_details: true, status_car: @event.status })
        ]
      end
    end
  end

  def hide_details
    device_id = params[:device_id]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: resolve_partial("home/details_blank"), locals: {device_id: device_id}),
          turbo_stream.replace("details_button_#{device_id}", partial: resolve_partial("home/details_button"), locals: { device_id: device_id, show_details: false, status_car: params[:status] })
        ]
      end
    end
  end

  def block_and_desblock
    @detail = Detail.find_by(device_id: params[:id])
    if Current.user.maintenance?
      # Vai direto para o comando sem salvar checklist
    else
      checklist_params = params.permit(
        :freios, :luzes, :pneus, :estepe, :oleo, :buzina,
        :painel, :doc, :retrovisor, :parabrisa, :limpador,
        :macaco, :lataria, :obs
      )

      boolean_fields = %w[freios luzes pneus estepe oleo buzina painel doc retrovisor parabrisa limpador macaco lataria]
      unchecked_fields = boolean_fields.select { |field| checklist_params[field] != 'true' }

      if unchecked_fields.any? && checklist_params[:obs].blank?
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.append(
              "flash",
              partial: "shared/flash_popup",
              locals: { alert_message: "É obrigatório preencher o campo 'Observações' quando algum item do checklist não for verificado." }
            )
          end
          format.html { redirect_to root_path, alert: "É obrigatório preencher o campo 'Observações' quando algum item do checklist não for verificado." }
        end
        return
      end

      checklist = CheckList.new(
        user_id: Current.user.id.to_s,
        detail_id: params[:id],
        type: params[:action_type],
        freios: checklist_params[:freios] == 'true',
        luzes: checklist_params[:luzes] == 'true',
        pneus: checklist_params[:pneus] == 'true',
        estepe: checklist_params[:estepe] == 'true',
        oleo: checklist_params[:oleo] == 'true',
        buzina: checklist_params[:buzina] == 'true',
        painel: checklist_params[:painel] == 'true',
        doc: checklist_params[:doc] == 'true',
        retrovisor: checklist_params[:retrovisor] == 'true',
        parabrisa: checklist_params[:parabrisa] == 'true',
        limpador: checklist_params[:limpador] == 'true',
        macaco: checklist_params[:macaco] == 'true',
        lataria: checklist_params[:lataria] == 'true',
        obs: checklist_params[:obs]
      )

      unless checklist.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.append(
              "flash",
              partial: "shared/flash_popup",
              locals: { alert_message: "Erro ao salvar checklist: #{checklist.errors.full_messages.join(', ')}" }
            )
          end
          format.html { redirect_to root_path, alert: "Erro ao salvar checklist: #{checklist.errors.full_messages.join(', ')}" }
        end
        return
      end
    end

    command_name = params[:action_type] == 'bloquear' ? 'rele_on' : 'rele_off'

    if @detail.category == 'motorcycle'
      if command_name == 'rele_on'
        command_name = 'rele_off'
      else
        command_name = 'rele_on'
      end
    end

    command = Command.find_by(type_device: params[:model], name: command_name)
    send_command = command.type_device == 'st8310u' ? command.command.gsub('XXXX', params[:imei]) : command.command

    response = Traccar.command(params[:id], send_command)

    if response != 200
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Erro ao enviar o comando: #{params[:action_type]}." }
          )
        end
        format.html { redirect_to root_path, alert: "Erro ao enviar o comando: #{params[:action_type]}." }
      end
      return
    end

    @detail.last_user = params[:action_type] == 'bloquear' ? '' : Current.user.name
    @detail.save
    create_event_log('commandSend', "#{command_name} / #{send_command}", @detail.device_id, @detail.device_name, "#{params[:action_type]} - Resposta: #{response}", @detail.last_user)

    driver_active = @detail.last_user.to_s.split(' ').first.presence || @detail.last_user
    Traccar.update_contact(@detail.device_id, @detail.device_name, driver_active, @detail.imei, @detail.category)

    notice = "Aguarde alguns segundos e o veículo será #{params[:action_type] == 'bloquear' ? 'BLOQUEADO' : 'DESBLOQUEADO'}."
    new_button_text = 'Aguarde...'
    new_button_class = 'btn'

    flash.now[:notice] = notice

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("button_#{params[:id]}", partial: "home/button", locals: { button_text: new_button_text, button_class: new_button_class }),
          turbo_stream.append("flash", partial: "/alert", locals: { notice: notice }),
          turbo_stream.append("flash", partial: "shared/flash_popup", locals: { notice_message: notice, redirect_on_success: true })
        ]
      end
    end
  end

  def last_events
    device_id = params[:device_id]

    if params[:open] == 'true'
      @events = query_events(device_id)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "events_#{device_id}",
            partial: resolve_partial("home/events"),
            locals: { device_id: device_id, events: @events }
          )
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "events_#{device_id}",
            partial: resolve_partial("home/events_blank"),
            locals: { device_id: device_id }
          )
        end
      end
    end
  end

  def odometro
    send_command = SendCommand.new(params[:model], params[:device_id], params[:command], params[:imei])
    response = ''
    case params[:command]
    when 'zerar_hodometro'
      response_rastreador = send_command.reset_odometer
      response_traccar = Traccar.reset_odometro(params[:device_id])
      response = "#{response_rastreador} | #{response_traccar}\n Em breve o valor será atualizado!"
    when 'zerar_horimetro'
      response_rastreador = send_command.reset_hour_meter
      response_traccar = Traccar.reset_horimetro(params[:device_id])
      response = "#{response_rastreador} | #{response_traccar}\n Em breve o valor será atualizado!"
    when 'parametros'
      response = send_command.params
    else
      response = "Comando desconhecido: #{params[:command]}"
    end

    flash.now[:notice] = response

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("flash", partial: "/alert", locals: { notice: response }),
          turbo_stream.append("flash", partial: "shared/flash_popup", locals: { notice_message: response })
        ]
      end
      format.html { redirect_to root_path, notice: response }
    end
  end

  def battery_history
    @device_id = params[:car_id]
    @detail = Detail.find_by(device_id: @device_id)

    if @detail.nil?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Dispositivo não encontrado." }
          )
        end
      end
      return
    end
    start_time = 4.days.ago

    @bat = Battery.where(device_id: @device_id, created_at: start_time..Time.current)
            .order(created_at: :asc)
            .pluck(:created_at, :bat)
            .map { |date, bat| [date.strftime("%H:%M:%S %d/%m/%Y"), bat.to_f] }

    @bkp = Battery.where(device_id: @device_id, created_at: start_time..Time.current)
            .order(created_at: :asc)
            .pluck(:created_at, :bkp)
            .map { |date, bkp| [date.strftime("%H:%M:%S %d/%m/%Y"), bkp.to_f] }

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "battery_history_modal",
          partial: "home/battery_history_modal",
          locals: { device_name: @detail.device_name, bat: @bat, bkp: @bkp }
        )
      end
    end
  end

  def historico_km
    @device_id = params[:car_id]
    @detail = Detail.find_by(device_id: @device_id)

    if @detail.nil?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Dispositivo não encontrado." }
          )
        end
      end
      return
    end

    # Busca registros dos últimos 3 meses
    data_limite = 3.months.ago.to_date
    mes_limite = data_limite.month
    ano_limite = data_limite.year

    semanais = Historico.where(device_id: @device_id, tipo: 'semanal')
                        .where("ano > ? OR (ano = ? AND numero >= ?)", ano_limite, ano_limite, data_limite.cweek)
                        .order(:ano, :numero)
    mensais  = Historico.where(device_id: @device_id, tipo: 'mensal')
                        .where("ano > ? OR (ano = ? AND numero >= ?)", ano_limite, ano_limite, mes_limite)
                        .order(:ano, :numero)

    # Monta os dados intercalados: semanas do mês X, depois total do mês X, etc.
    meses_index = mensais.index_by { |m| [m.ano, m.numero] }

    # Agrupa semanas por mês/ano usando a data aproximada da semana
    semanas_por_mes = {}
    semanais.each do |s|
      # Calcula a data da segunda-feira dessa semana ISO
      data_semana = Date.commercial(s.ano, s.numero, 1) rescue Date.new(s.ano, 1, 1)
      chave = [data_semana.year, data_semana.month]
      semanas_por_mes[chave] ||= []
      semanas_por_mes[chave] << s
    end

    # Coleta todos os meses que aparecem (das semanas ou dos registros mensais)
    todos_meses = (semanas_por_mes.keys + meses_index.keys).uniq.sort

    @labels = []
    @valores = []
    @cores = []

    todos_meses.each do |ano, mes|
      # Semanas desse mês
      (semanas_por_mes[[ano, mes]] || []).each do |s|
        @labels << "Semana #{s.numero}"
        @valores << s.odometro.to_f.round(2)
        @cores << '#4299e1' # azul para semanas
      end

      # Total do mês
      if meses_index[[ano, mes]]
        m = meses_index[[ano, mes]]
        @labels << m.descricao
        @valores << m.odometro.to_f.round(2)
        @cores << '#48bb78' # verde para meses
      end
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "historico_km_modal",
          partial: "home/historico_km_modal",
          locals: {
            device_name: @detail.device_name,
            labels: @labels,
            valores: @valores,
            cores: @cores
          }
        )
      end
    end
  end

  def acordar_rastreador
    device_id = params[:device_id]
    detail = Detail.find_by(device_id: device_id)

    resp = send_command_sms('acordar', detail)

    if resp == 200
      notice = "Comando para acordar o rastreador enviado com sucesso. Aguarde alguns instantes e atualize a página."
      flash.now[:notice] = notice

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("flash", partial: "/alert", locals: { notice: notice }),
            turbo_stream.append("flash", partial: "shared/flash_popup", locals: { notice_message: notice, redirect_on_success: true })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Erro ao enviar o comando para acordar o rastreador. Resposta: #{resp}" }
          )
        end
        format.html { redirect_to root_path, alert: "Erro ao enviar o comando para acordar o rastreador. Resposta: #{resp}" }
      end
    end
  end

  private

  def query_events(device_id)
    Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current)
      .where.not(event_name: IGNORED_EVENT_NAMES)
      .where.not(event_type: IGNORED_EVENT_TYPES)
      .order(created_at: :desc)
  end

  def devices_admin
    return Detail.where("LOWER(device_name) LIKE LOWER(:query)", query: "%#{params[:query].downcase}%") if params[:query].present?
    Detail.all
  end

  def devices_user
    if Current.user&.pessoal && Current.user&.active == false
      return Detail.none
    end

    device_ids = Current.user&.cars.present? ? Current.user.cars.split(",") : []
    if params[:query].present?
      devices = device_ids.present? ? Detail.where("LOWER(device_name) LIKE LOWER(:query)", query: "%#{params[:query].downcase}%").where(device_id: device_ids) : []
    else
      devices = device_ids.present? ? Detail.where(device_id: device_ids) : []
    end

    devices
  end

  def send_command(command_name)
    command = Command.find_by(type_device: @event.model, name: command_name)
    send_command = command.present? ? command.command : nil
    return if send_command.nil?
    send_command = send_command.gsub('XXXX', @event.imei) if @event.model == 'st8310u'

    SendCommandJob.perform_later({device_id: @event.device_id, command: send_command})
  end

  def send_command_sms(command_name, detail)
    command = Command.find_by(type_device: detail.model, name: command_name)
    send_command = command.present? ? command.command_sms : nil
    return if send_command.nil?
    response = SendSms.send_sms(detail.cell_number, send_command, detail.device_id)
    msg = "VEÍCULO: #{detail.device_name}(#{detail.device_id}) | CELL: #{detail.cell_number} | SMS: #{send_command} | Resposta: #{response}"
    SaveLog.new('sleep_motos', msg).save
    response
  end

  def define_text(event, status)
    return "Veículo hibernando" if status == 'offline' && event.sleeping == true
    return "Veículo off-line" if status == 'offline'
    return "Veículo sem histórico. Você pode bloquear/desbloquear." if event.nil?
    return "Em uso por #{event.last_user}." if event.rele_state == 'off'
    "Veículo disponível."
  end

  def define_state(event)
    return "bloquear"    if event.nil? # Se não tem evento, pode bloquear, porque, por padrão o rastreador iniciar desbloqueado
    return "desbloquear" if event.rele_state == 'on' # Qualquer um pode desbloquear, porque o veículo está bloqueado e disponível para uso
    return "bloquear"    if event.rele_state == 'off' && event.last_user == Current.user.name # Se o evento é desbloquear e o motorista é o mesmo que desbloqueou, ele pode bloquear
    return "bloquear"    if event.rele_state == 'off' && Current.user.admin? # Se o evento é desbloquear e o motorista é admin, ele pode bloquear
    return "not_user" # se chegar aqui, é porque o evento é desbloquear e o motorista é diferente do que desbloqueou, então ele não pode bloquear
  end

  helper_method :define_text, :define_state

  def get_info_device
    response = Traccar.get_info_device(params[:device_id])

    if response.empty?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Erro ao buscar informações do veículo." }
          )
        end
        format.html { redirect_to root_path, alert: "Erro ao buscar informações do veículo." }
      end
      return
    end

    response
  end

  def create_event_log(event_type, event_name, car_id, device_name, message, driver_active = '')
    Event.create(
      car_id: car_id,
      car_name: device_name,
      driver_name: driver_active,
      event_type: event_type,
      event_name: event_name,
      message: message
    )
  end
end
