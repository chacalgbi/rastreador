class HomeController < ApplicationController
  HOURS_LAST_EVENTS = 96
  before_action :set_global_variables

  def set_global_variables
    @user_admin = Current.user.admin?
  end

  def index
    @devices = Current.user.admin? ? devices_admin : devices_user
    return render partial: "indexpartial", locals: { devices: @devices } if turbo_frame_request?
    @search_query = params[:query].present?
    @devices = Kaminari.paginate_array(@devices).page(params[:page]).per(10)
  end

  def location
    @location_url = params[:url]
    redirect_to root_path, alert: "Erro ao buscar a posição do veículo." if @location_url.empty?

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
    @events_last_x_hours = Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current).where.not(event_name: 'resposta').count

    send_command('Status')
    send_command('network')

    info = @event
    msg = define_text(@event, params[:status])
    state = define_state(@event)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: "home/details", locals: {status: params[:status], info: info, msg: msg, device_id: device_id, state: state, events_count: @events_last_x_hours, user_maintenance: Current.user.maintenance?}),
          turbo_stream.replace("details_button_#{device_id}", partial: "home/details_button", locals: { device_id: device_id, show_details: true, status_car: @event.status })
        ]
      end
    end
  end

  def hide_details
    device_id = params[:device_id]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: "home/details_blank", locals: {device_id: device_id}),
          turbo_stream.replace("details_button_#{device_id}", partial: "home/details_button", locals: { device_id: device_id, show_details: false, status_car: params[:status] })
        ]
      end
    end
  end

  def block_and_desblock
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
        redirect_to root_path, alert: "É obrigatório preencher o campo 'Observações' quando algum item do checklist não for verificado."
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
        redirect_to root_path, alert: "Erro ao salvar checklist: #{checklist.errors.full_messages.join(', ')}"
        return
      end
    end

    command_name = params[:action_type] == 'bloquear' ? 'rele_on' : 'rele_off'
    command = Command.find_by(type_device: params[:model], name: command_name)
    send_command = command.type_device == 'st8310u' ? command.command.gsub('XXXX', params[:imei]) : command.command

    response = Traccar.command(params[:id], send_command)

    if response != 200
      redirect_to root_path, alert: "Erro ao enviar o comando: #{params[:action_type]}."
      return
    end

    @detail = Detail.find_by(device_id: params[:id])
    @detail.last_user = params[:action_type] == 'bloquear' ? '' : Current.user.name
    @detail.save

    driver_active = @detail.last_user.to_s.split(' ').first.presence || @detail.last_user
    Traccar.update_contact(@detail.device_id, @detail.device_name, driver_active, @detail.imei)

    notice = "Aguarde alguns segundos e o veículo será #{params[:action_type] == 'bloquear' ? 'BLOQUEADO' : 'DESBLOQUEADO'}."
    new_button_text = 'Aguarde...'
    new_button_class = 'btn'

    flash.now[:notice] = notice

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("button_#{params[:id]}", partial: "home/button", locals: { button_text: new_button_text, button_class: new_button_class }),
          turbo_stream.append("flash", partial: "/alert", locals: { notice: notice })
        ]
      end
    end
  end

  def last_events
    device_id = params[:device_id]

    if params[:open] == 'true'
      @events = Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current).where.not(event_name: 'resposta').order(created_at: :desc)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "events_#{device_id}",
            partial: "home/events",
            locals: { device_id: device_id, events: @events }
          )
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "events_#{device_id}",
            partial: "home/events_blank",
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
        render turbo_stream: turbo_stream.append(
          "flash",
          partial: "/alert",
          locals: { notice: response }
        )
      end
      format.html { redirect_to root_path, notice: response }
    end
  end

  private

  def devices_admin
    return Detail.where("LOWER(device_name) LIKE LOWER(:query)", query: "%#{params[:query].downcase}%") if params[:query].present?
    Detail.all
  end

  def devices_user
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

    #SendCommandJob.perform_later({device_id: @event.device_id, command: send_command})
    Traccar.command(@event.device_id, send_command) # Temporariamente até ver o problema do job
  end

  def define_text(event, status)
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

  def get_info_device
    response = Traccar.get_info_device(params[:device_id])
    redirect_to root_path, alert: "Erro ao buscar informações do veículo." if response.empty?

    response
  end
end
