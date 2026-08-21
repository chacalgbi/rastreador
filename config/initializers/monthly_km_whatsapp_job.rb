Rails.application.config.after_initialize do
  if Rails.env.production?
    Thread.new do
      sleep 10
      Rails.logger.info("\n\nIniciando SendMonthlyKmWhatsappJob recorrente...\n\n")
      SendMonthlyKmWhatsappJob.start_recurring
    end
  end
end
