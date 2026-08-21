require 'fileutils'

class SaveLog
  # Tipos que simplesmente gravam @log em log/informacao/<type>.log
  SIMPLE_TYPES = %w[
    info error_payload error_alert redefinir_senha enviar_sms error params
    alert_job sleep_motos notify_error push_notification_error
    payload_desconhecido search_stopped_motorcycles notify_temp_block
    monthly_km_whatsapp
  ].freeze

  # Cache de loggers para evitar recriar instâncias a cada chamada.
  # Class instance variables: não são compartilhadas com subclasses,
  # evitando surpresas caso SaveLog seja herdada.
  @loggers = {}
  @dirs_created = {}
  @mutex = Mutex.new

  class << self
    def get_logger(path, file_name)
      file = File.join(path, file_name)
      @mutex.synchronize do
        unless @dirs_created[path.to_s]
          FileUtils.mkdir_p(path)
          @dirs_created[path.to_s] = true
        end
        @loggers[file] ||= Logger.new(file, 10, 5 * 1024 * 1024)
      end
    end
  end

  def initialize(type, log, log2 = nil, log3 = nil)
    @type = type
    @log = log
    @log2 = log2
    @log3 = log3
  end

  def save
    if @type == 'event_car'
      event_car
    elsif SIMPLE_TYPES.include?(@type)
      write_info_log(@type)
    end
  rescue StandardError => e
    Rails.logger.error("SaveLog.save | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}\n\n")
    nil
  end

  private

  def event_car
    return nil if @log.dig(:device, :id).nil? || @log.dig(:device, :name).nil?
    device_name = "#{@log.dig(:device, :id)}_#{@log.dig(:device, :name)}".downcase.gsub(/[^a-z0-9]/, '_')
    path = Rails.root.join('log', 'carros')

    logger = self.class.get_logger(path, "#{device_name}.log")
    logger.info("\nPARAMETROS: #{@log}\nPADRONIZADO: #{@log2 || 'Sem padronização'}\nALERTA: #{@log3 || 'Sem alertas'}\n")
  end

  # Grava @log em log/informacao/<name>.log
  def write_info_log(name)
    logger = self.class.get_logger(Rails.root.join('log', 'informacao'), "#{name}.log")
    logger.info("#{@log}\n")
  end
end
