class StandardizePayload::Xt40
  def initialize(payload, detail)
    @payload = payload
    @detail = detail
  end

  def standardize
    begin
      @type = @payload.dig(:event, :type)

      case @type
      when 'ignitionOn'
        ignitionOn
      when 'ignitionOff'
        ignitionOff
      when 'deviceMoving'
        deviceMoving
      when 'deviceStopped'
        deviceStopped
      when 'geofenceExit'
        geofenceExit
      when 'geofenceEnter'
        geofenceEnter
      when 'deviceOverspeed'
        deviceOverspeed
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
        nil
      end
    rescue StandardError => e
      error_message = "StandardizePayload::Xt40 | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error(error_message)
      SaveLog.new('error_payload', error_message).save
      nil
    end
  end

    private

  def ignitionOn
    {
      device_name: @payload.dig(:device, :name),
      ignition: @payload.dig(:position, :attributes, :ignition) ? 'on' : 'off',
      last_event_type: @type,
      url: url_google_maps,
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      horimetro: horas,
      odometro: kilometros,
      cercas: @payload.dig(:position, :geofenceIds).join(','),
      imei: @payload.dig(:device, :uniqueId),
      bat_nivel: "#{@payload.dig(:position, :attributes, :batteryLevel)}%",
      charge: @payload.dig(:position, :attributes, :charge) ? 'on' : 'off',
      status: @payload.dig(:device, :status)
    }
  end

  def ignitionOff
    {
      device_name: @payload.dig(:device, :name),
      ignition: @payload.dig(:position, :attributes, :ignition) ? 'on' : 'off',
      last_event_type: @type,
      url: url_google_maps,
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      horimetro: horas,
      odometro: kilometros,
      cercas: @payload.dig(:position, :geofenceIds).join(','),
      imei: @payload.dig(:device, :uniqueId),
      bat_nivel: "#{@payload.dig(:position, :attributes, :batteryLevel)}%",
      charge: @payload.dig(:position, :attributes, :charge) ? 'on' : 'off',
      status: @payload.dig(:device, :status)
    }
  end

  def deviceMoving
    {
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      imei: @payload.dig(:device, :uniqueId),
      last_event_type: @type,
      url: url_google_maps
      # horimetro: horas, // Verificar se os valores são parciais ou totais
      # odometro: kilometros,
    }
  end

  def deviceStopped
    {
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      imei: @payload.dig(:device, :uniqueId),
      last_event_type: @type,
      url: url_google_maps
      # horimetro: horas, // Verificar se os valores são parciais ou totais
      # odometro: kilometros,
    }
  end

  def geofenceExit
    {
      device_name: @payload.dig(:device, :name),
      last_event_type: @type,
      url: url_google_maps,
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      imei: @payload.dig(:device, :uniqueId),
      status: @payload.dig(:device, :status)
    }
  end

  def geofenceEnter
    {
      device_name: @payload.dig(:device, :name),
      last_event_type: @type,
      url: url_google_maps,
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      imei: @payload.dig(:device, :uniqueId),
      status: @payload.dig(:device, :status)
    }
  end

  def deviceOverspeed
    {
      last_event_type: @type,
      speed: km_por_hora(@payload.dig(:event, :attributes, :speed) || 0),
      velo_max: km_por_hora(@payload.dig(:event, :attributes, :speedLimit) || 0),
      url: url_google_maps,
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
    }
  end

  def deviceOffline
    {
      device_name: @payload.dig(:device, :name),
      last_event_type: @type,
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      imei: @payload.dig(:device, :uniqueId),
      status: @payload.dig(:device, :status)
    }
  end

  def alarm
    {
      device_name: @payload.dig(:device, :name),
      last_event_type: define_alarm_type(@payload.dig(:event, :attributes, :alarm)),
      url: url_google_maps,
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      imei: @payload.dig(:device, :uniqueId),
      status: @payload.dig(:device, :status)
    }
  end

  def commandResult
    commandResult_type = @payload.dig(:position, :attributes, :result)

    if commandResult_type.start_with?('SET DYD,OK!')
      commandResult_releOn
    elsif commandResult_type.start_with?('SET HFYD,OK!')
      commandResult_releOff
    elsif commandResult_type.start_with?('BATTERY')
      commandResult_status
    elsif commandResult_type.start_with?('APN')
      commandResult_params
    else
      nil
    end
  end

  def deviceOnline
    nil # Não envia alerta
  end

  def deviceUnknown
    nil # Não envia alerta
  end

  # ============= Helpers ===============

  def url_google_maps
    "https://www.google.com/maps?q=#{@payload.dig(:position, :latitude)},#{@payload.dig(:position, :longitude)}"
  end

  def horas
    milissegundos = @payload.dig(:position, :attributes, :hours) || 0
    segundos = milissegundos / 1000
    minutos = segundos / 60
    horas = minutos / 60
    "#{horas.to_i}h"
  end

  def kilometros
    # decimo_de_milhas = @payload.dig(:position, :attributes, :totalDistance) || 0
    # milhas = decimo_de_milhas / 10
    # "#{(milhas * 1.60934).round(1)}km"
    metros = @payload.dig(:position, :attributes, :totalDistance) || 0
    km = metros / 1000
    "#{(km * 1.60934).round(1)}km"
  end

  def km_por_hora(milhas_nauticas)
    km_por_hora = (milhas_nauticas * 1.853).to_i
    "#{km_por_hora} km/h"
  end

  def define_alarm_type(alarme_type)
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

  # ============= Helpers Command ===============

  def commandResult_releOn
    {
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
      imei: @payload.dig(:device, :uniqueId),
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      rele_state: 'on',
      last_event_type: "Rele on",
      url: url_google_maps,
      last_rele_modified: Time.now
    }
  end

  def commandResult_releOff
    {
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
      imei: @payload.dig(:device, :uniqueId),
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      rele_state: 'off',
      last_event_type: "Rele off",
      url: url_google_maps,
      last_rele_modified: Time.now
    }
  end

  def commandResult_status
    status = decode_status_string(@payload.dig(:position, :attributes, :result))
    {
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
      imei: @payload.dig(:device, :uniqueId),
      velo_max: km_por_hora(@payload.dig(:device, :attributes, :speedLimit) || 0),
      horimetro: horas,
      odometro: kilometros,
      url: url_google_maps,
      cercas: @payload.dig(:position, :geofenceIds) ? @payload.dig(:position, :geofenceIds).join(',') : nil,
      last_event_type: "Status",
      ignition: status["ACC"].start_with?('ON') ? 'on' : 'off',
      rele_state: status["RELAYER"] == 'DISABLE' ? 'off' : 'on',
      battery: status['VOLTAGE'].split(',').first.to_f.round(2) || 0,
      bat_bck: status['VOLTAGE'].split(',').last.to_f.round(2) || 0,
      signal_gps: "#{status["GPS"]},#{status["GPS SIGNAL"]}",
      signal_gsm: status["GSM Signal"],
      acc_virtual: status["ACCVIRT"].start_with?('ON') ? 'on' : 'off',
      charge: status["CHARGER"].start_with?('NORMAL') ? 'on' : 'off'
    }
  end

  def commandResult_params
    params = @payload.dig(:position, :attributes, :result).split(" ")
    {
      device_name: @payload.dig(:device, :name),
      status: @payload.dig(:device, :status),
      imei: @payload.dig(:device, :uniqueId),
      last_event_type: "params",
      url: url_google_maps,
      apn: params[0],
      ip_and_port: params[1]
    }
  end

  def decode_status_string(status)
    status_array = status.split("\n")
    status_pairs = status_array.map { |s| s.split(':') }
    status_pairs.to_h
  end
end


# {
#   device_name:
#   model:
#   ignition:
#   rele_state:
#   last_event_type:
#   last_user:
#   last_rele_modified:
#   url:
#   velo_max:
#   battery:
#   bat_bck:
#   horimetro:
#   odometro:
#   cercas:
#   satelites:
#   version:
#   imei:
#   bat_nivel:
#   signal_gps:
#   signal_gsm:
#   acc:
#   acc_virtual:
#   charge:
#   heartbeat:
#   obs:
#   status:
#   network:
#   params:
#   apn:
#   ip_and_port:
# }
