require 'net/http'
require 'uri'
require 'json'

class SendSms
  def self.send_sms(cell, message, device_id)
    payload = {
      message: "sms_rastreador:#{cell}_#{message}_#{device_id}_#{ENV["SERVIDOR"]}"
    }

    uri = URI("#{ENV["SMS_API_URL"]}/sms_rastreador")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = payload.to_json
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      log("send_sms SUCESSO | Response: #{response.code.to_i}")
    else
      log("send_sms ERRO | #{response.code} #{response.body}")
    end

    SaveLog.new('enviar_sms', "Payload: #{payload[:message]} Response: #{response.code} #{response.body}").save

    response.code.to_i
  end

  private

  def self.log(message)
    msg = "SendSms.#{message}"
    Rails.logger.info(msg)
  end
end
