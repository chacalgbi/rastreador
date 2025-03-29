require 'net/http'
require 'uri'
require 'json'

class Traccar
  @@global_cookies = nil

  def self.session
    log("session - iniciada")
    session = ENV["TRACCAR_TOKEN_SESSION"]
    url_server = ENV["TRACCAR_URL"]

    url = URI("#{url_server}/api/session?token=#{session}")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      full_cookie = response['Set-Cookie']
      log("session SUCESSO | Cookies: #{full_cookie}")
      @@global_cookies = full_cookie.split(';').first
      log("session SUCESSO | Cookie recebido: #{@@global_cookies}")
    else
      log("session ERRO | status: #{response.code} - #{response.body}")
    end
  end

  def self.get_info_device(device_id)
    log("get_info_device #{device_id}")

    url = URI.parse("#{ENV["TRACCAR_URL"]}/api/positions?deviceId=#{device_id}")

    http = Net::HTTP.new(url.hostname, url.port)
    http.use_ssl = (url.scheme == 'https')
    request = Net::HTTP::Get.new(url.request_uri)
    request['Cookie'] = @@global_cookies if @@global_cookies
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    elsif response.code.to_i == 401
      log("get_info_device ERRO | 401 Tentando autenticar novamente")
      self.session
      self.get_info_device(device_id) # Tenta novamente após autenticar
    else
      log("get_info_device ERRO | #{response.code} #{response.body}")
      []
    end
  end

  def self.command(device_id, command)
    log("command #{device_id} - #{command}")

    payload = {
      deviceId: device_id,
      description: "Comando personalizado",
      type: "custom",
      attributes: {
        data: command
      }
    }

    uri = URI("#{ENV["TRACCAR_URL"]}/api/commands/send")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request['Cookie'] = @@global_cookies if @@global_cookies
    request.body = payload.to_json
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      log("command SUCESSO | Response: #{response.code.to_i}")
    elsif response.code.to_i == 401
      log("command ERRO | 401 Tentando autenticar novamente")
      self.session
      self.command(device_id, command) # Tenta novamente após autenticar
    else
      log("command ERRO | #{response.code} #{response.body}")
    end

    response.code.to_i
  end

  private

  def self.log(message)
    msg = "Traccar.#{message}"
    Rails.logger.info(msg)
  end
end
