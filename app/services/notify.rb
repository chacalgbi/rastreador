require 'net/http'
require 'uri'
require 'json'
require 'cgi'

class Notify

  def self.email(email, titulo, corpo)
    payload = {
      email: email,
      titulo: titulo,
      corpo: corpo,
      identidade: "Notify.email #{email}",
      userAdmin: ENV["NOTIFY_USER"],
      passAdmin: ENV["NOTIFY_PASS"]
    }

    log("email #{payload}")

    uri = URI(ENV["NOTIFY_EMAIL"])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = payload.to_json
    response = http.request(request)
    data = JSON.parse(response.body)
    log("email ERRO #{response.code} #{data}") unless response.is_a?(Net::HTTPSuccess)
    data
  end

  def self.telegram(chat_id, corpo)
    encoded_text = CGI.escape(corpo)
    url = "https://api.telegram.org/bot#{ENV["TOKEN_BOT"]}/sendMessage?chat_id=#{chat_id}&text=#{encoded_text}"

    response = Net::HTTP.get_response(URI(url))
    if response.is_a?(Net::HTTPSuccess)
      resp = JSON.parse(response.body)
      log("telegram SUCCESS | Enviado para #{resp.dig('result', 'chat', 'username')}")
    else
      log("telegram ERRO | #{response.code} #{response.body}")
    end

    true
  end

  private

  def self.log(message)
    msg = "Notify.#{message}"
    Rails.logger.info(msg)
  end
end
