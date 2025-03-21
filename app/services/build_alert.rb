class BuildAlert
  def initialize(payload, detail)
    @payload = payload
    @detail = detail
  end

  def build
    begin
      @type = @payload.dig(:event, :type)

      define_values

      case @type
      when 'ignitionOn'
        ignitionOn
      when 'ignitionOff'
        ignitionOff
      when 'geofenceExit'
        geofenceExit
      when 'geofenceEnter'
        geofenceEnter
      when 'deviceOverspeed'
        deviceOverspeed
      when 'deviceMoving'
        deviceMoving
      when 'deviceStopped'
        deviceStopped
      when 'deviceOffline'
        deviceOffline
      when 'deviceOnline'
        deviceOnline
      when 'deviceUnknown'
        deviceUnknown
      when 'alarm'
        alarm
      when 'commandResult'
        commandResult
      else
        standard
      end
    rescue StandardError => e
      error_message = "BuildAlert | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error(error_message)
      SaveLog.new('error_alert', error_message).save
      nil
    end
  end

  private

  def define_values
    @motorista = @detail.last_user || 'Motorista não identificado'
    @alert_whatsApp = @detail.alert_whatsApp
    @alert_telegram = @detail.alert_telegram
    @alert_email = @detail.alert_email

    @veiculo = @payload.dig(:device, :name)
    @email = @payload.dig(:device, :contact)
    @phone = @payload.dig(:device, :phone)
    @telegram = @payload.dig(:device, :model)
  end

  def ignitionOn
    msg1 = "O veículo '#{@veiculo}' está com a ignição 🔵LIGADA."
    events(@type, 'ligado', msg1)
    nil
  end

  def ignitionOff
    msg1 = "O veículo '#{@veiculo}' está com a ignição 🔴DESLIGADA."
    events(@type, 'desligado', msg1)
    nil
  end

  def deviceMoving
    msg1 = "O veículo '#{@veiculo}' está em MOVIMENTO."
    events(@type, 'movendo', msg1)
    nil
  end

  def deviceStopped
    msg1 = "O veículo '#{@veiculo}' está PARADO."
    events(@type, 'parado', msg1)
    nil
  end

  def geofenceExit
    cerca = @payload.dig(:geofence, :name)
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' SAIU da cerca '#{cerca}'.\n\nLocal: #{url_google_maps}"
    msg2 = "⚠️ AVISO! ⚠️\n\n#{msg1}"

    events(@type, 'cerca', msg1)
    return nil unless @detail.send_exit_cerca

    payload_job_send_alert(msg2, @type)
  end

  def geofenceEnter
    cerca = @payload.dig(:geofence, :name)
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' ENTROU da cerca '#{cerca}'.\n\nLocal: #{url_google_maps}"
    msg2 = "💬 INFORMAÇÃO 💬\n\n#{msg1}"

    events(@type, 'cerca', msg1)

    return nil unless @detail.send_exit_cerca
    payload_job_send_alert(msg2, @type)
  end

  def deviceOverspeed
    velocidade = km_por_hora(@payload.dig(:event, :attributes, :speed))
    limite = km_por_hora(@payload.dig(:event, :attributes, :speedLimit))

    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' em VELOCIDADE ACIMA do permitido: #{velocidade}.\n\nLimite: #{limite} \n\nLocal: #{url_google_maps}"
    msg2 = "🚨 ALERTA! 🚨\n\n#{msg1}"

    events(@type, 'velocidade', msg1)

    return nil unless @detail.send_velo_max
    payload_job_send_alert(msg2, @type)
  end

  def deviceOffline
    msg1 = "O veículo '#{@veiculo}' está 🔴OFF-LINE."
    #msg2 = "💬 INFORMAÇÃO 💬\n\n"

    events(@type, 'Off-Line', msg1)

    nil
  end

  def alarm
    alarme_type = @payload.dig(:event, :attributes, :alarm)
    alarme_text = alarme_type(alarme_type)
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' disparou o alarme '#{alarme_text}'.\n\nLocal: #{url_google_maps}"
    msg2 = "🚨 ALERTA! 🚨\n\n#{msg1}"

    events(@type, alarme_type, msg1)

    return nil unless @detail.send_battery
    payload_job_send_alert(msg2, alarme_type)
  end

  def commandResult
    msg1 = @payload.dig(:position, :attributes, :result)
    events(@type, 'resposta', msg1)
    nil
  end

  def deviceOnline
  end

  def deviceUnknown
  end

  def standard
  end

  # ========== HELPERS ==========

  def km_por_hora(milhas_nauticas)
    km_por_hora = (milhas_nauticas * 1.853).to_i
    "#{km_por_hora} km/h"
  end

  def url_google_maps
    "https://www.google.com/maps?q=#{@payload.dig(:position, :latitude)},#{@payload.dig(:position, :longitude)}"
  end

  def events(event_type, event_name, msg1)
    Event.create(
      car_id: @detail.device_id,
      car_name: @veiculo,
      driver_name: @motorista,
      event_type: event_type,
      event_name: event_name,
      message: msg1
    )
  end

  def payload_job_send_alert(msg2, event)
    {
      alert_whatsApp: @alert_whatsApp,
      alert_telegram: @alert_telegram,
      alert_email: @alert_email,
      message: msg2,
      phone: @phone,
      email: @email,
      telegram: @telegram,
      event: event
    }
  end

  def alarme_type(alarme_type)
    case alarme_type
    when 'lowBattery'
      'Bateria baixa'
    when 'powerCut'
      'Corte de energia'
    when 'sos'
      'SOS'
    else
      'Alarme desconhecido'
    end
  end
end
