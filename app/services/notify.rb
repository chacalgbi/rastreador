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

    uri = URI(ENV["NOTIFY_EMAIL"])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = payload.to_json
    response = http.request(request)
    data = JSON.parse(response.body)

    if response.is_a?(Net::HTTPSuccess)
      log("email SUCCESS | Enviado para #{email}")
    else
      log_msg = "email ERRO | Email: #{email}, Msg: #{corpo}, Response_code: #{response.code}, Response_body: #{data}"
      log(log_msg)
      SaveLog.new('notify_error', "Notify.#{log_msg}").save
    end

    true
  end

  def self.telegram(chat_id, corpo)
    begin
      encoded_text = CGI.escape(corpo)
      url = "https://api.telegram.org/bot#{ENV["TOKEN_BOT"]}/sendMessage?chat_id=#{chat_id}&text=#{encoded_text}"

      log("telegram | URL: #{url}")

      response = Net::HTTP.get_response(URI(url))
      resp = JSON.parse(response.body)

      if response.is_a?(Net::HTTPSuccess)
        log("telegram SUCCESS | Enviado para #{resp.dig('result', 'chat', 'username')}")
      else
        log_msg = "telegram ERRO | Chat_id: #{chat_id}, Msg: #{corpo}, Response_code: #{response.code}, Response_body: #{resp}"
        log(log_msg)
        SaveLog.new('notify_error', "Notify.#{log_msg}").save
      end

      true
    rescue StandardError => e
      log("telegram ERRO | Exception: #{e.message}")
      SaveLog.new('notify_error', "Notify.telegram | Exception: #{e.message}").save
      false
    end
  end

  def self.whatsapp(cel_number, corpo)
    begin
      payload = {
        identidade: "Notify.whatsapp #{cel_number}",
        userAdmin: ENV["NOTIFY_USER"],
        passAdmin: ENV["NOTIFY_PASS"],
        cel: cel_number.gsub(/\D/, ''),
        msg: corpo
      }

      log("whatsapp | Payload: #{payload}")

      uri = URI(ENV["NOTIFY_WHATSAPP"])
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      request.body = payload.to_json
      response = http.request(request)
      data = JSON.parse(response.body)

      if response.is_a?(Net::HTTPSuccess)
        log("whatsapp SUCCESS | Enviado para #{cel_number}")
      else
        log_msg = "whatsapp ERRO | Payload: #{payload}, Response_code: #{response.code}, Response_body: #{data}"
        log(log_msg)
        SaveLog.new('notify_error', "Notify.#{log_msg}").save
      end

      true
    rescue StandardError => e
      log("whatsapp ERRO | Exception: #{e.message}")
      SaveLog.new('notify_error', "Notify.whatsapp | Exception: #{e.message}").save
      false
    end
  end

  private

  def self.log(message)
    msg = "Notify.#{message}"
    Rails.logger.info(msg)
  end
end
