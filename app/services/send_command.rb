class SendCommand
  def initialize(model, device_id, command, imei)
    @model = model
    @device_id = device_id
    @command = command
    @imei = imei
    @send_command = define_send_command
  end

  def reset_odometer
    return error_command unless @send_command
    response = Traccar.command(@device_id, @send_command)
    return "Erro ao resetar hodômetro: #{response}" if response != 200
    "Hodômetro resetado com sucesso: #{response}"
  end

  def reset_hour_meter
    return error_command unless @send_command
    response = Traccar.command(@device_id, @send_command)
    return "Erro ao resetar horímetro: #{response}" if response != 200
    "Horímetro resetado com sucesso: #{response}"
  end

  private

  def define_send_command
    command = Command.find_by(type_device: @model, name: @command)
    return nil unless command
    send_command = command.type_device == 'st8310u' ? command.command.gsub('XXXX', @imei) : command.command
    send_command
  end

  def error_command
    "Comando desconhecido: '#{@command}' para o modelo '#{@model}' device_id: '#{@device_id}'."
  end
end
