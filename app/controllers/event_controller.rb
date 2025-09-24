class EventController < PublicController
  skip_before_action :verify_authenticity_token, only: [:webhook_traccar, :webhook_traccar_sms]
  def webhook_traccar
    @detail = Detail.find_by(device_id: params[:device][:id])

    if @detail.nil?
      return render json: { msg: "veiculo não encontrado: #{params[:device][:id]}" }, status: :not_found
    else
      build_events
      render json: { msg: "ok" }, status: :ok
    end

  end

  def webhook_traccar_sms
    build_sms
    render json: { msg: "ok" }, status: :ok
  end

  private

  def build_events
    standardized_data = StandardizePayload::Decoder.new(params, @detail).decide
    return if standardized_data.nil?

    build_alert = BuildAlert.new(standardized_data, @detail).build

    TraccarUpdateDevice.new(standardized_data, @detail).update

    SaveLog.new('event_car', params, standardized_data, build_alert).save

    return if build_alert.nil?
    SendAlertJob.perform_later(build_alert)
  end

  def build_sms
    result = params[:message].split('_')
    response = result[0] == '1' ? 'Sucesso' : 'Falha' # status do envio do sms pelo ESP12-E
    tag = result[0] == '1' ? '🟢' : '🔴'
    detail = Detail.find_by(device_id: result[1])
    comando = result[2] # comando enviado

    return if detail.nil?

    msg = "#{tag} RESPOSTA SMS >> Status: #{response} | Comando: #{comando} | Veículo #{detail.device_name}(#{detail.device_id}) | Número: #{detail.cell_number}"
    SaveLog.new('enviar_sms', msg).save

    Event.create(
      car_id: detail.device_id,
      car_name: detail.device_name,
      driver_name: detail.last_user,
      event_type: 'sms_callback',
      event_name: 'resposta',
      message: msg
    )

  rescue StandardError => e
    error_message = "EventController.build_sms | | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
    Rails.logger.error(error_message)
    SaveLog.new('error', error_message).save
    nil
  end
end
