class EventController < PublicController
  skip_before_action :verify_authenticity_token, only: [:webhook_traccar]
  def webhook_traccar
    @detail = Detail.find_by(device_id: params[:device][:id])

    if @detail.nil?
      return render json: { msg: "detail not found" }, status: :not_found
    else
      build_events
      render json: { msg: "ok" }, status: :ok
    end

  end

  private

  def build_events
    standardized_data = StandardizePayload::Decoder.new(params, @detail).decide
    return if standardized_data.nil?

    SaveLog.new('event_car', params, standardized_data).save

    build_alert = BuildAlert.new(standardized_data, @detail).build

    TraccarUpdateDevice.new(standardized_data, @detail).update

    return if build_alert.nil?
    SendAlertJob.perform_later(build_alert)
  end
end
