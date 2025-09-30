Rails.application.config.after_initialize do
  if Rails.env.production?
    Thread.new do
      sleep 10
      Rails.logger.info("\n\nIniciando SearchStoppedMotorcyclesJob recorrente...\n\n")
      SearchStoppedMotorcyclesJob.start_recurring
    end
  end
end
