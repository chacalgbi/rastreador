require 'net/http'
require 'uri'
require 'json'

class HomeController < ApplicationController
  def index
    response = Net::HTTP.get_response(URI(ENV["DEVICES_URL"]))

    if response.is_a?(Net::HTTPSuccess)
      @devices = JSON.parse(response.body)
    else
      redirect_to root_path, alert: "Erro ao buscar os veículos: #{response.code}. Msg: #{response.body}"
    end
  end

  def location
    response = Net::HTTP.get_response(URI("#{ENV["POSITION_URL"]}#{params[:car_id]}"))

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      @location_url = data["message"]
    else
      redirect_to root_path, alert: "Erro ao buscar a posição do veículo: #{response.code}. Msg: #{response.body}"
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
    @event = Event.where(car_id: device_id).order(created_at: :desc).first
    @events_last_48_hours = Event.where(car_id: device_id, created_at: 48.hours.ago..Time.current).count

    msg = define_text(@event)
    state = define_state(@event)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("details_#{device_id}", partial: "home/details", locals: { msg: msg, device_id: device_id, state: state, events_count: @events_last_48_hours }),
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

    uri = URI(ENV["COMMAND_URL"])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = payload.to_json
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      notice = "#{data}. Aguarde alguns segundos e o veículo será #{action_type == 'bloquear' ? 'BLOQUEADO' : 'DESBLOQUEADO'}."
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
    else
      redirect_to root_path, alert: "Erro ao enviar o comando: #{action_type}. Msg: #{response.body}."
    end
  end

  private

  def define_text(event)
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
    return "not_user" # se chegar aqui, é porque o evento é desbloquear e o motorista é diferente do que desbloqueou, então ele não pode bloquear
  end
end
