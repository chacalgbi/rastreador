require 'net/http'
require 'uri'
require 'json'

class SendSms
  # def self.send_sms(cell, message, device_id)
  #   # Este método usa o mqtt para enviar sms pelo ESP8266 e o SIM800L
  #   # Ele envia para http://ip_de_qa:8087/sms_rastreador que por sua vez envia para o broker mqtt
  #   # no tópico '/mini_monit/device4550/terminal_IN' a mensagem abaixo.
  #   # No esp8266 ele verifica se a mensagem começa com 'sms_rastreador:' e envia o sms
  #   # caso o módulo SIM800L envie a mensagem ele responde no tópico '/rastreadores/sms_response'
  #   # Dentro do node ele recebe a resposta e trata sucesso/erro e manda o webHook para os endereços abaixo:
  #   # API_WEBHOOK_LOCAL = 'http://127.0.0.1:3000/event/webhook_traccar_sms' # LOCALHOST
  #   # API_WEBHOOK_CTE = 'https://url_cte/event/webhook_traccar_sms' # PRODUCAO CTE
  #   # API_WEBHOOK_QA = 'https://url_qa/event/webhook_traccar_sms' # PRODUCAO QA
  #   payload = {
  #     message: "#{cell}_#{message}_#{device_id}_#{ENV["SERVIDOR"]}"
  #   }

  #   uri = URI("#{ENV["SMS_API_URL"]}/sms_rastreador")
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = false
  #   request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  #   request.body = payload.to_json
  #   response = http.request(request)

  #   if response.is_a?(Net::HTTPSuccess)
  #     log("send_sms SUCESSO | Response: #{response.code.to_i}")
  #   else
  #     log("send_sms ERRO | #{response.code} #{response.body}")
  #   end

  #   SaveLog.new('enviar_sms', "Payload: #{payload[:message]} Response: #{response.code} #{response.body}").save

  #   response.code.to_i
  # end

  def self.send(cell, message, device_id, type)
    # type deve ter dois valores: "GENERIC ou COMMAND" para indicar que é uma mensagem genérica, ou seja sem salvar na tabela
    # de retorno no EVENTS de um veículo específico. será apenas salvo o log.
    # Esse método vai usar o padrão abaixo:
    # POST http://devrails.com.br/alertaSms
    # { "identidade":"descrição", "userAdmin":"...", "passAdmin": "...", "cel":"...", "msg":"..." }
    # Um registro de notificação é criado na tabela notifications.
    # dentro do servidor IOT manda para seu proprio local host no node.js
    # O Node.js recebe na rota /alertaSms e publica na fila /thome_lucas/send_sms
    # O celular sansung com o termux instalado fica escutando essa fila e envia o sms
    # Devolve o callback na fila mqtt /rastreadores/sms_response
    # Um serviço node.js no servidor de QA escuta essa fila e manda o webHook para o WebHook definido.
    # Padrão da mensagem de callback: "status_celular_deviceid_message_servidor_type_statusMessage"

    begin
      celular = cell.gsub(/\D/, '')
      payload = {
        identidade: "SendSms.send #{cell} Device: #{device_id}",
        userAdmin: ENV["NOTIFY_USER"],
        passAdmin: ENV["NOTIFY_PASS"],
        cel: celular,
        msg: "#{celular}_#{message}_#{device_id}_#{ENV["SERVIDOR"]}_#{type}"
      }

      log("send | Payload: #{payload}")

      uri = URI(ENV["NOTIFY_SMS"])
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      request.body = payload.to_json
      response = http.request(request)
      data = JSON.parse(response.body)

      if response.is_a?(Net::HTTPSuccess)
        log("send SUCCESS | Enviado para #{cell}")
      else
        log_msg = "send ERRO | Payload: #{payload}, Response_code: #{response.code}, Response_body: #{data}"
        log(log_msg)
        SaveLog.new('notify_error', "SendSms.send | #{log_msg}").save
      end

      data
    rescue StandardError => e
      log("send ERRO | Exception: #{e.message}")
      SaveLog.new('notify_error', "SendSms.send | Exception: #{e.message} | #{e.backtrace.first(6).join("\n")}").save
      false
    end
  end

  private

  def self.log(message)
    msg = "SendSms.#{message}"
    Rails.logger.info(msg)
  end
end
