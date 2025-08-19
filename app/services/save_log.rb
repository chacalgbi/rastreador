require 'fileutils'

class SaveLog
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
      when 'error'
        error
      when 'params'
        params
      when 'alert_job'
        alert_job
      when 'notify_error'
        notify_error
      else
        nil
      end
    rescue StandardError => e
      Rails.logger.error("SaveLog.save | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}\n\n")
      nil
    end
  end

  private

  def event_car
    return nil if @log.dig(:device, :id).nil? || @log.dig(:device, :name).nil?
    device_name = "#{@log.dig(:device, :id)}_#{@log.dig(:device, :name)}".downcase.gsub(/[^a-z0-9]/, '_')
    path = Rails.root.join('log', 'carros')
    file = File.join(path, "#{device_name}.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("\nPARAMETROS: #{@log}\nPADRONIZADO: #{@log2 || 'Sem padronização'}\nALERTA: #{@log3 || 'Sem alertas'}\n")
  end

  def info
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "info.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def error_payload
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "error_payload.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def error_alert
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "error_alert.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def error
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "error.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def alert_job
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "alert_job.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def notify_error
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "notify_error.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def params
    path = Rails.root.join('log', 'informacao')
    file = File.join(path, "params.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end
end
