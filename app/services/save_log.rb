require 'fileutils'

class SaveLog
  # Cache de loggers para evitar recriar instâncias a cada chamada
  @@loggers = {}
  @@mutex = Mutex.new
  @@dirs_created = {}

  def initialize(type, log, log2 = nil, log3 = nil)
    @type = type
    @log = log
    @log2 = log2
    @log3 = log3
  end

  def save
    begin
      case @type
      when 'event_car'
        event_car
      when 'info'
        info
      when 'error_payload'
        error_payload
      when 'error_alert'
        error_alert
      when 'redefinir_senha'
        redefinir_senha
      when 'enviar_sms'
        enviar_sms
      when 'error'
        error
      when 'params'
        params
      when 'alert_job'
        alert_job
      when 'sleep_motos'
        sleep_motos
      when 'notify_error'
        notify_error
      when 'push_notification_error'
        push_notification_error
      when 'payload_desconhecido'
        payload_desconhecido
      when 'search_stopped_motorcycles'
        search_stopped_motorcycles
      else
        nil
      end
    rescue StandardError => e
      Rails.logger.error("SaveLog.save | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}\n\n")
      nil
    end
  end

  private

  def self.get_logger(path, file_name)
    file = File.join(path, file_name)
    @@mutex.synchronize do
      unless @@dirs_created[path.to_s]
        FileUtils.mkdir_p(path)
        @@dirs_created[path.to_s] = true
      end
      @@loggers[file] ||= Logger.new(file, 10, 5 * 1024 * 1024)
    end
  end

  def event_car
    return nil if @log.dig(:device, :id).nil? || @log.dig(:device, :name).nil?
    device_name = "#{@log.dig(:device, :id)}_#{@log.dig(:device, :name)}".downcase.gsub(/[^a-z0-9]/, '_')
    path = Rails.root.join('log', 'carros')

    logger = self.class.get_logger(path, "#{device_name}.log")
    logger.info("\nPARAMETROS: #{@log}\nPADRONIZADO: #{@log2 || 'Sem padronização'}\nALERTA: #{@log3 || 'Sem alertas'}\n")
  end

  def info
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "info.log")
    logger.info("#{@log}\n")
  end

  def error_payload
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "error_payload.log")
    logger.info("#{@log}\n")
  end

  def error_alert
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "error_alert.log")
    logger.info("#{@log}\n")
  end

  def redefinir_senha
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "redefinir_senha.log")
    logger.info("#{@log}\n")
  end

  def enviar_sms
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "enviar_sms.log")
    logger.info("#{@log}\n")
  end

  def error
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "error.log")
    logger.info("#{@log}\n")
  end

  def alert_job
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "alert_job.log")
    logger.info("#{@log}\n")
  end

  def sleep_motos
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "sleep_motos.log")
    logger.info("#{@log}\n")
  end

  def notify_error
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "notify_error.log")
    logger.info("#{@log}\n")
  end

  def push_notification_error
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "push_notification_error.log")
    logger.info("#{@log}\n")
  end

  def params
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "params.log")
    logger.info("#{@log}\n")
  end

  def payload_desconhecido
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "payload_desconhecido.log")
    logger.info("#{@log}\n")
  end

  def search_stopped_motorcycles
    path = Rails.root.join('log', 'informacao')
    logger = self.class.get_logger(path, "search_stopped_motorcycles.log")
    logger.info("#{@log}\n")
  end
end
