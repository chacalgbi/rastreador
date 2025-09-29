class SearchStoppedMotorcyclesJob < ApplicationJob
  queue_as :search_stopped_motorcycles

  def self.perform
    begin
      Rails.logger.info("SearchStoppedMotorcyclesJob.perform")
      SaveLog.new('search_stopped_motorcycles', "Iniciando verificação de motocicletas paradas com ignição desligada.").save
    rescue StandardError => e
      error_message = "SearchStoppedMotorcyclesJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error', error_message).save
      raise e
    ensure
      self.class.set(wait: 30.minutes).perform_later
    end
  end

  def self.start_recurring
    perform_later unless already_scheduled?
  end

  private

  def self.already_scheduled?
    SolidQueue::Job.where(class_name: name, finished_at: nil).exists?
  rescue
    false # Se der erro na consulta, permite criar o job
  end
end
