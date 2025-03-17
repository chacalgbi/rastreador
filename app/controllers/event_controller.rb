class EventController < PublicController
  skip_before_action :verify_authenticity_token, only: [:webhook_traccar]
  def webhook_traccar
    standardized_data, detail = StandardizePayload::Decoder.new(params).decide
    log("webhook_traccar - standardized_data: #{standardized_data}")
    # TraccarUpdateDevice.new(standardized_data, detail).update

    render json: { msg: "ok" }, status: :ok
  end

  private

  def log(message)
    msg = "\n\nEventController.#{message}"
    Rails.logger.info(msg)
  end
end
