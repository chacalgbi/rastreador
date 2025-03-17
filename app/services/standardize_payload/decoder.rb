class StandardizePayload::Decoder
  def initialize(payload)
    @payload = payload
  end

  def decide
    detail = Detail.find_by(device_id: @payload[:device][:id])

    return nil if @detail.nil?

    standardize_payload = nil

    case detail.model
    when "xt40"
      standardize_payload = StandardizePayload::Xt40.new(@payload, detail).standardize
    when "st8310u"
      standardize_payload = StandardizePayload::St8310u.new(@payload, detail).standardize
    else
      nil
    end

    [standardize_payload, detail]
  end
end
