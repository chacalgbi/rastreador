class BuildAlert
  def initialize(payload, detail)
    # '🚙🚗🚘🚨⚠️✅📣📢🪫📡⌛🔋🔓🔒💬🔴🟠🟡🟢🗺️'
    @payload = payload
    @detail = detail
  end

  def build
    begin
      @type = @payload.dig(:last_event_type)

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
      when 'alarm'
        alarm
      when 'commandResult'
        commandResult
      else
        nil
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

    @veiculo = @payload.dig(:device_name) || @detail.device_name
    @email = @payload.dig(:email)
    @phone = @payload.dig(:phone)
    @telegram = @payload.dig(:telegram)
    @cerca = @payload.dig(:cerca)
    @url = @payload.dig(:url)
    @velocidade = @payload.dig(:velocidade)
    @velo_max = @payload.dig(:velo_max)
    @alarme = @payload.dig(:last_event_type)
    @alarme_type = @payload.dig(:alarme_type)
    @command = @payload.dig(:command)
    @rele = @payload.dig(:rele_state)
    @odometro = @payload.dig(:odometro)
    @last_rele_modified = @payload.dig(:last_rele_modified)
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
    odometro = @odometro ? "\n\nOdômetro: #{@odometro}" : ''
    url = @url ? "\n\nLocal: #{@url}" : ''
    msg1 = "O veículo '#{@veiculo}' está em MOVIMENTO. 🚗💨.#{odometro}#{url}"
    events(@type, 'movendo', msg1)

    return nil unless @detail.send_moving
    payload_job_send_alert(msg1, @type)
  end

  def deviceStopped
    odometro = @odometro ? "\n\nOdômetro: #{@odometro}" : ''
    url = @url ? "\n\nLocal: #{@url}" : ''
    msg1 = "O veículo '#{@veiculo}' está PARADO.#{odometro}#{url}"
    events(@type, 'parado', msg1)

    return nil unless @detail.send_moving
    payload_job_send_alert(msg1, @type)
  end

  def geofenceExit
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' SAIU da cerca '#{@cerca}'.\n\nLocal: #{@url}"
    msg2 = "⚠️ AVISO! ⚠️\n\n#{msg1}"

    events(@type, 'cerca', msg1)
    return nil unless @detail.send_exit_cerca

    payload_job_send_alert(msg2, @type)
  end

  def geofenceEnter
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' ENTROU da cerca '#{@cerca}'.\n\nLocal: #{@url}"
    msg2 = "💬 INFORMAÇÃO 💬\n\n#{msg1}"

    events(@type, 'cerca', msg1)

    return nil unless @detail.send_exit_cerca
    payload_job_send_alert(msg2, @type)
  end

  def deviceOverspeed
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' em VELOCIDADE ACIMA do permitido: #{@velocidade}.\n\nLimite: #{@velo_max} \n\nLocal: #{@url}"
    msg2 = "🚨 ALERTA! 🚨\n\n#{msg1}"

    events(@type, 'velocidade', msg1)

    return nil unless @detail.send_velo_max
    payload_job_send_alert(msg2, @type)
  end

  def deviceOffline
    msg1 = "O veículo '#{@veiculo}' está 🔴OFF-LINE."
    events(@type, 'Off-Line', msg1)
    nil
  end

  def alarm
    url = @url ? "\n\nLocal: #{@url}" : ''
    alarme_text = alarme_type(@alarme_type)
    msg1 = "Veículo '#{@veiculo}' em uso por '#{@motorista}' disparou o alarme '#{alarme_text}'.#{url}"
    msg2 = "🚨 ALERTA! 🚨\n\n#{msg1}"

    events(@type, @alarme_type, msg1)

    return nil unless @detail.send_battery
    payload_job_send_alert(msg2, @alarme_type)
  end

  def commandResult
    if !@last_rele_modified.nil? && (@rele == 'on' || @rele == 'off')
      msg1 = "O veículo '#{@veiculo}' foi #{@rele == 'on' ? '🔒BLOQUEADO' : '🔓DESBLOQUEADO'}."
      msg2 = "💬 INFORMAÇÃO! 💬\n\n#{msg1}"
      events(@type, 'rele', msg1)
      return nil unless @detail.send_rele
      payload_job_send_alert(msg2, @type)
    else
      msg1 = @command
      events(@type, 'resposta', msg1)
      nil
    end
  end

  # ========== HELPERS ==========

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
      '🪫Bateria baixa'
    when 'powerCut'
      '🪫Corte de energia'
    when 'sos'
      '📣SOS'
    when 'powerRestored'
      '🔋Energia restaurada'
    when 'accident'
      'Acidente'
    else
      'Alarme desconhecido'
    end
  end
end
