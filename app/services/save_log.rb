require 'fileutils'

class SaveLog
  def initialize(type, log)
    @log = log
    @type = type
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
      else
        nil
      end
    rescue StandardError => e
      Rails.logger.error("SaveLog.save - #{e.message}")
      nil
    end
  end

  private

  def event_car
    return nil if @log.dig(:device, :id).nil? || @log.dig(:device, :name).nil?
    device_name = "#{@log.dig(:device, :id)}_#{@log.dig(:device, :name)}".downcase.gsub(' ', '_')
    path = Rails.root.join('log', 'carros')
    file = File.join(path, "#{device_name}.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
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
    path = Rails.root.join('log', 'error_payload')
    file = File.join(path, "error_payload.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end

  def error_alert
    path = Rails.root.join('log', 'error_alert')
    file = File.join(path, "error_alert.log")

    FileUtils.mkdir_p(path) unless File.directory?(path)

    FileUtils.touch(file)

    logger = Logger.new(file, 10, 5 * 1024 * 1024) # 10 arquivos de backup, 5MB cada
    logger.info("#{@log}\n")
  end
end
