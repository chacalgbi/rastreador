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
      when 'commandResult'
        commandResult
      when 'alarm'
        alarm
      else
        SaveLog.new('payload_desconhecido', @payload).save
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

  def atributos_comuns
    {
      last_event_type: @type,
      alarme_type: @payload.dig(:event, :attributes, :alarm),
      device_name: @payload.dig(:device, :name),
      email:       NotificationCacheService.email_addresses,
      phone:       NotificationCacheService.whatsapp_numbers,
      telegram:    NotificationCacheService.telegram_ids,
      status:      @payload.dig(:device, :status) == 'online' ? 'online' : 'offline',
      imei:        @payload.dig(:device, :uniqueId),
      url:         url_google_maps,
      velo_max:    km_por_hora(@payload.dig(:device, :attributes, :speedLimit)),
      velocidade:  km_por_hora(@payload.dig(:event, :attributes, :speed) || 0),
      cerca:       @payload.dig(:geofence, :name),
      command:     @payload.dig(:position, :attributes, :result)
    }
  end

  def ignitionOn
    {
      ignition: @payload.dig(:position, :attributes, :ignition) ? 'on' : 'off',
      horimetro: horas,
      odometro: kilometros,
      cercas: @payload.dig(:position, :geofenceIds) ? @payload.dig(:position, :geofenceIds).join(',') : nil,
      bat_nivel: "#{@payload.dig(:position, :attributes, :batteryLevel)}%",
      charge: @payload.dig(:position, :attributes, :charge) ? 'on' : 'off',
      **atributos_comuns
    }
  end

  def ignitionOff
    {
      ignition: @payload.dig(:position, :attributes, :ignition) ? 'on' : 'off',
      horimetro: horas,
      odometro: kilometros,
      cercas: @payload.dig(:position, :geofenceIds) ? @payload.dig(:position, :geofenceIds).join(',') : nil,
      bat_nivel: "#{@payload.dig(:position, :attributes, :batteryLevel)}%",
      charge: @payload.dig(:position, :attributes, :charge) ? 'on' : 'off',
      **atributos_comuns
    }
  end

  def deviceMoving
    {
      odometro: kilometros,
      horimetro: horas,
      **atributos_comuns
    }
  end

  def deviceStopped
    {
      odometro: kilometros,
      horimetro: horas,
      **atributos_comuns
    }
  end

  def geofenceExit
    {
      horimetro: horas,
      odometro: kilometros,
      **atributos_comuns
    }
  end

  def geofenceEnter
    {
      horimetro: horas,
      odometro: kilometros,
      **atributos_comuns
    }
  end

  def deviceOverspeed
    {
      **atributos_comuns
    }
  end

  def deviceUnknown
    {
      **atributos_comuns
    }
  end

  def deviceOffline
    {
      **atributos_comuns
    }
  end

  def deviceOnline
    {
      **atributos_comuns
    }
  end

  def alarm
    {
      **atributos_comuns
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
    elsif commandResult_type.start_with?('NetworkMode')
      commandResult_network
    elsif commandResult_type.start_with?('SPEEDCHECK')
      commandResult_speedcheck
    elsif commandResult_type.start_with?('ICCID')
      commandResult_iccid
    elsif commandResult_type.start_with?('ECLEAN MILEAGE NUM')
      commandResult_clean_odometro
    elsif commandResult_type.start_with?('CLEAN ACC ONLINE TIME')
      commandResult_clean_horimetro
    elsif commandResult_type.start_with?('queuedCommandSent')
      commandResult_queuedCommandSent
    else
      SaveLog.new('payload_desconhecido', @payload).save
      nil
    end
  end

  def commandResult_queuedCommandSent
    {
      **atributos_comuns
    }
  end

  def commandResult_clean_odometro
    {
      **atributos_comuns
    }
  end

  def commandResult_clean_horimetro
    {
      **atributos_comuns
    }
  end

  def commandResult_iccid
    iccid = @payload.dig(:position, :attributes, :result).split(':').last.strip
    {
      iccid: iccid,
      **atributos_comuns
    }
  end

  def commandResult_speedcheck
    {
      **atributos_comuns
    }
  end

  def commandResult_releOn
    estado_rele = @detail.category == "motorcycle" ? 'off' : 'on' # Necessário pois quando for moto, o relé deve ficar ligado quando o veículo estiver em uso.
    # lembrar que o relé é invertido em motos. Bomba de combutível funciona com o relé ligado. Pino 30 a 87.
    # No chicote fio amarelo e vermelho (isolar o fio preto).
    {
      rele_state: estado_rele,
      last_rele_modified: Time.now,
      **atributos_comuns
    }
  end

  def commandResult_releOff
    estado_rele = @detail.category == "motorcycle" ? 'on' : 'off' # Necessário pois quando for moto, o relé deve ficar desligado quando o veículo estiver parado.
    {
      rele_state: estado_rele,
      last_rele_modified: Time.now,
      **atributos_comuns
    }
  end

  def commandResult_status
    status = decode_status_string(@payload.dig(:position, :attributes, :result))
    {
      horimetro: horas,
      odometro: kilometros,
      cercas: @payload.dig(:position, :geofenceIds) ? @payload.dig(:position, :geofenceIds).join(',') : nil,
      ignition: status["ACC"].start_with?('ON') ? 'on' : 'off',
      rele_state: status["RELAYER"] == 'DISABLE' ? 'off' : 'on',
      battery: status['VOLTAGE'].split(',').first.to_f.round(2) || 0,
      bat_bck: status['VOLTAGE'].split(',').last.to_f.round(2) || 0,
      signal_gps: "#{status["GPS"]},#{status["GPS SIGNAL"]}",
      signal_gsm: status["GSM Signal"],
      acc_virtual: status["ACCVIRT"].start_with?('ON') ? 'on' : 'off',
      charge: status["CHARGER"].start_with?('NORMAL') ? 'on' : 'off',
      **atributos_comuns
    }
  end

  def commandResult_params
    params = @payload.dig(:position, :attributes, :result)
    params_array = params.split(" ")
    other_params = extract_params(params) || []
    {
      apn: params_array[0],
      ip_and_port: params_array[1],
      heartbeat: other_params[1],
      params: "#{other_params[0]} #{other_params[2]} #{other_params[3]}",
      **atributos_comuns
    }
  end

  def commandResult_network
    params = @payload.dig(:position, :attributes, :result)
    result = NetworkParserXt40.new(params).parse
    return nil unless result
    result_parsed = "#{result[:network_mode]} #{result[:signal_strength]}% #{result[:signal_quality]} #{result[:frequency_band]} #{result[:operator]}"
    {
      network: result_parsed,
      **atributos_comuns
    }
  end

  # ============= Helpers ===============

  def decode_status_string(status)
    status_array = status.split("\n")
    status_pairs = status_array.map { |s| s.split(':') }
    status_pairs.to_h
  end

  def url_google_maps
    return nil unless @payload.dig(:position, :latitude) && @payload.dig(:position, :longitude)
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
    "#{km.round(2)}km"
  end

  def km_por_hora(milhas_nauticas)
    return nil if milhas_nauticas.nil?
    km_por_hora = (milhas_nauticas * 1.853).to_i
    "#{km_por_hora} km/h"
  end

  def extract_params(params)
    begin
      target_keys = ["GMT", "HBT", "MIL", "BEND"]
      extracted_data = {}

      # Regex para encontrar as chaves desejadas e capturar seus valores
      # (?:...) -> grupo não capturante
      # \s* -> zero ou mais espaços após o ':'
      # (.*?) -> captura o valor (não guloso)
      # (?=...) -> lookahead positivo para encontrar o limite do valor
      # \s+[A-Z]{2,}: -> próximo delimitador (espaço + chave com 2+ letras maiúsculas + :)
      # |$ -> ou o fim da string
      regex = /(#{target_keys.join("|")}):\s*(.*?)(?=\s+[A-Z]{2,}:|$)/

      params.scan(regex).each do |key, value|
        extracted_data[key] = value.strip
      end
      result_array = extracted_data.map { |key, value| "#{key}: #{value}" }

      # extracted_data: {"GMT" => "W3", "HBT" => "5.10", "MIL" => "ON<0.01km>", "BEND" => "ON.15  BD"}
      # result_array:   ["GMT: W3", "HBT: 5.10", "MIL: ON<0.01km>", "BEND: ON.15  BD"]

      result_array
    rescue StandardError => e
      error_message = "StandardizePayload::Xt40.extract_params | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error_payload', error_message).save
      nil
    end
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
