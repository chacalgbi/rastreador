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
  private

  def self.log(message)
    msg = "Traccar.#{message}"
    Rails.logger.info(msg)
  end
end


  # def self.get_devices(ids = nil)
  #   log("get_devices #{ids}")

  #   if ids.nil?
  #     url = ENV["DEVICES_URL"]
  #   else
  #     id_params = ids.map { |id| "id=#{id}" }.join("&")
  #     url = "#{ENV["DEVICES_URL"]}?#{id_params}"
  #   end

  #   response = Net::HTTP.get_response(URI(url))
  #   if response.is_a?(Net::HTTPSuccess)
  #     JSON.parse(response.body)
  #   else
  #     log("get_devices ERRO #{response.code} #{response.body}")
  #     []
  #   end
  # end

  # def self.get_position(car_id)
  #   log("get_position #{car_id}")
  #   response = Net::HTTP.get_response(URI("#{ENV["POSITION_URL"]}#{car_id}"))

  #   if response.is_a?(Net::HTTPSuccess)
  #     data = JSON.parse(response.body)
  #     data["message"]
  #   else
  #     log("get_position ERRO #{response.code} #{response.body}")
  #     ""
  #   end
  # end

  # def self.block_and_desblock(payload)
  #   log("block_and_desblock #{payload}")
  #   uri = URI(ENV["COMMAND_URL"])
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  #   request.body = payload.to_json
  #   response = http.request(request)

  #   if response.is_a?(Net::HTTPSuccess)
  #     JSON.parse(response.body)
  #   else
  #     log("block_and_desblock ERRO #{response.code} #{response.body}")
  #     ""
  #   end
  # end

  # def self.get_info_device(device_id)
  #   log("get_info_device #{device_id}")
  #   response = Net::HTTP.get_response(URI("#{ENV["INFO_URL"]}#{device_id}"))

  #   if response.is_a?(Net::HTTPSuccess)
  #     JSON.parse(response.body)
  #   else
  #     log("get_info_device ERRO #{response.code} #{response.body}")
  #     {
  #       deviceId: device_id,
  #       satelite: 'n/a',
  #       battery: 'n/a',
  #       bat_bckp: 'n/a',
  #       altitude: 'n/a',
  #       geofenceIds: [],
  #       ignition: false,
  #       version: 'n/a',
  #       type: 'n/a'
  #     }.with_indifferent_access
  #   end
  # end
