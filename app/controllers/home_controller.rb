class HomeController < ApplicationController
  HOURS_LAST_EVENTS = 100

  def index
    if Current.user.admin?
      @devices = Traccar.get_devices
    else
      device_ids = Current.user&.cars.present? ? Current.user.cars.split(",") : []
      @devices = device_ids.present? ? Traccar.get_devices(device_ids) : []
    end

    @devices = Kaminari.paginate_array(@devices).page(params[:page]).per(10)
  end

  def location
    @location_url = Traccar.get_position(params[:car_id])
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
    @event = Event.where(car_id: device_id, event_name: ['bloquear', 'desbloquear']).order(created_at: :desc).first
    @events_last_x_hours = Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current).count

    info = get_info_device
    msg = define_text(@event, params[:status])
    state = define_state(@event)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: "home/details", locals: {status: params[:status], info: info, msg: msg, device_id: device_id, state: state, events_count: @events_last_x_hours, event: @event}),
          turbo_stream.replace("details_button_#{device_id}", partial: "home/details_button", locals: { device_id: device_id, show_details: true })
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
          turbo_stream.replace("details_button_#{device_id}", partial: "home/details_button", locals: { device_id: device_id, show_details: false })
        ]
      end
    end
  end

  def block_and_desblock
    device_id = params[:id]
    action_type = params[:action_type]

    payload = {
      driver_id: Current.user.id,
      device_id: device_id,
      driver_name: Current.user.name,
      command: action_type
    }

    response = Traccar.block_and_desblock(payload)
    redirect_to root_path, alert: "Erro ao enviar o comando: #{action_type}." if response.empty?

    notice = "#{response}. Aguarde alguns segundos e o veículo será #{action_type == 'bloquear' ? 'BLOQUEADO' : 'DESBLOQUEADO'}."
    new_button_text = 'Aguarde...'
    new_button_class = 'btn'

    flash.now[:notice] = notice

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("button_#{device_id}", partial: "home/button", locals: { button_text: new_button_text, button_class: new_button_class }),
          turbo_stream.append("flash", partial: "/alert", locals: { notice: notice })
        ]
      end
    end
  end

  def last_events
    device_id = params[:device_id]

    if params[:open] == 'true'
      @events = Event.where(car_id: device_id, created_at: HOURS_LAST_EVENTS.hours.ago..Time.current).order(created_at: :desc)

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

  def define_text(event, status)
    return "Veículo off-line" if status != 'online'
    return "Veículo sem histórico. Você pode bloquear/desbloquear." if event.nil?
    text = "#{event.car_name} disponível."
    if event.event_name == 'desbloquear'
      time_in_utc_minus_3 = event.created_at.in_time_zone('America/Sao_Paulo')
      text = "Em uso por #{event.driver_name} desde #{time_in_utc_minus_3.strftime('%d/%m/%Y %H:%M')}"
    end
    text
  end

  def define_state(event)
    return "bloquear"    if event.nil? # Se não tem evento, pode bloquear, porque, por padrão o rastreador iniciar desbloqueado
    return "desbloquear" if event.event_name == 'bloquear' # Qualquer um pode desbloquear, porque o veículo está bloqueado e disponível para uso
    return "bloquear"    if event.event_name == 'desbloquear' && event.driver_id.to_i == Current.user.id # Se o evento é desbloquear e o motorista é o mesmo que desbloqueou, ele pode bloquear
    return "bloquear"    if event.event_name == 'desbloquear' && Current.user.admin? # Se o evento é desbloquear e o motorista é admin, ele pode bloquear
    return "not_user" # se chegar aqui, é porque o evento é desbloquear e o motorista é diferente do que desbloqueou, então ele não pode bloquear
  end

  def get_info_device
    response = Traccar.get_info_device(params[:device_id])
    redirect_to root_path, alert: "Erro ao buscar informações do veículo." if response.empty?

    response
  end
end
