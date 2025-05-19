class HomeController < ApplicationController
  HOURS_LAST_EVENTS = 48

  def index
    if Current.user.admin?
      @devices = Detail.all
      # Debugbar.msg("Devices", {devices: @devices})
    else
      device_ids = Current.user&.cars.present? ? Current.user.cars.split(",") : []
      @devices = device_ids.present? ? Detail.where(device_id: device_ids) : []
    end

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
    @events_last_x_hours = Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current).where.not(event_type: 'commandResult').count

    send_command_status

    info = @event
    msg = define_text(@event, params[:status])
    state = define_state(@event)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: "home/details", locals: {status: params[:status], info: info, msg: msg, device_id: device_id, state: state, events_count: @events_last_x_hours}),
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
      @events = Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current).where.not(event_type: 'commandResult').order(created_at: :desc)

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

  private

  def send_command_status
    command = Command.find_by(type_device: @event.model, name: 'Status')
    send_command = command.present? ? command.command : nil

    if @event.model == 'st8310u'
      send_command = send_command.gsub('XXXX', @event.imei)
    end

    Traccar.command(@event.device_id, send_command)
  end

  def define_text(event, status)
    return "Veículo off-line" if status == 'offline'
    return "Veículo sem histórico. Você pode bloquear/desbloquear." if event.nil?
    return "Em uso por #{event.last_user}." if event.rele_state == 'off'
    "#{event.device_name} disponível."
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
