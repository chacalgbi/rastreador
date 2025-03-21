class EventController < PublicController
  skip_before_action :verify_authenticity_token, only: [:webhook_traccar]
  def webhook_traccar
    @detail = Detail.find_by(device_id: params[:device][:id])

    if @detail.nil?
      log("webhook_traccar - detail not found")
      return render json: { msg: "detail not found" }, status: :not_found
    else
      build_events
      render json: { msg: "ok" }, status: :ok
    end

  end

  private

  def build_events
    SaveLog.new('event_car', params).save
    standardized_data = StandardizePayload::Decoder.new(params, @detail).decide
    log("build_events - standardized_data:\n #{standardized_data}")
    return if standardized_data.nil?

    build_alert = BuildAlert.new(params, @detail).build
    log("build_events - build_alert:\n #{build_alert}")

    TraccarUpdateDevice.new(standardized_data, @detail).update

    SendAlertJob.perform_later(build_alert)
  end

  def log(message)
    msg = "EventController.#{message}"
    Rails.logger.info("\n#{msg}\n")
    SaveLog.new('info', msg).save
  end
end
