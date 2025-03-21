class StandardizePayload::St8310u
  def initialize(payload, detail)
    @payload = payload
    @detail = detail
    @alert = BuildAlert.new(payload, detail)
  end

  def standardize
  end
end
