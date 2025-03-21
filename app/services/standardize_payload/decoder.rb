class StandardizePayload::Decoder
  def initialize(payload, detail)
    @payload = payload
    @detail = detail
  end

  def decide
    standardize_payload = nil

    case @detail.model
    when "xt40"
      standardize_payload = StandardizePayload::Xt40.new(@payload, @detail).standardize
    when "st8310u"
      standardize_payload = StandardizePayload::St8310u.new(@payload, @detail).standardize
    else
      nil
    end

    standardize_payload
  end
end
