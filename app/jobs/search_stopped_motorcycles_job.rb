class SearchStoppedMotorcyclesJob < ApplicationJob
  queue_as :search_stopped_motorcycles

  def perform
    begin
      Rails.logger.info("SearchStoppedMotorcyclesJob.perform")
      SaveLog.new('search_stopped_motorcycles', "Iniciando verificação de motocicletas paradas com ignição desligada.").save
    rescue StandardError => e
      error_message = "SearchStoppedMotorcyclesJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error', error_message).save
      raise e
    end
  end
end
