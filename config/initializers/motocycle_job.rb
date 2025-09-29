Rails.application.config.after_initialize do
  if Rails.env.production?
    Thread.new do
      sleep 10
      SearchStoppedMotorcyclesJob.start_recurring
    end
  end
end
