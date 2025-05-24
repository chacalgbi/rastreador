class StandardizePayload::St8310u
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
      email:       @payload.dig(:device, :contact),
      phone:       @payload.dig(:device, :phone),
      telegram:    @payload.dig(:device, :model),
      status:      @payload.dig(:device, :status) == 'online' ? 'online' : 'offline',
      imei:        @payload.dig(:device, :uniqueId),
      url:         url_google_maps,
      velo_max:    km_por_hora(@payload.dig(:device, :attributes, :speedLimit)),
      velocidade:  km_por_hora(@payload.dig(:event, :attributes, :speed) || 0),
      cerca:       @payload.dig(:geofence, :name),
      command:     @payload.dig(:position, :attributes, :result),
      battery:     @payload.dig(:position, :attributes, :io1),
      bat_bck:     @payload.dig(:position, :attributes, :io2),
      ignition:    @payload.dig(:position, :attributes, :ignition) ? 'on' : 'off',
      cercas:      @payload.dig(:position, :geofenceIds) ? @payload.dig(:position, :geofenceIds).join(',') : nil
    }
  end

  def ignitionOn
    {
      horimetro: horas,
      odometro:  kilometros,
      **atributos_comuns
    }
  end

  def ignitionOff
    {
      horimetro: horas,
      odometro: kilometros,
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
      horimetro: horas,
      odometro: kilometros,
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
    return nil if commandResult_type.nil?
    return commandResult_rele(commandResult_type) if commandResult_type.start_with?('04;0') # Comando de rele
    return atributos_comuns if commandResult_type.start_with?('01;03') # Requisitar Status

    nil
  end

    # ============= Helpers ===============

  def commandResult_rele(commandResult_type)
      array_commandResult_type = commandResult_type.split(';')
      state = array_commandResult_type[16] == '00000001' ? 'on' : 'off'
      {
        rele_state: state,
        last_rele_modified: Time.now,
        **atributos_comuns
      }
  end

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
