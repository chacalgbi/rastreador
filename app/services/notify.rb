require 'net/http'
require 'uri'
require 'json'

class Notify

  def self.email(email, titulo, corpo)
    payload = {
      email: email,
      titulo: titulo,
      corpo: corpo,
      identidade: "Rastreador recuperação de senha para #{email}",
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

  private

  def self.log(message)
    msg = "Notify.#{message}"
    Rails.logger.info(msg)
  end
end
