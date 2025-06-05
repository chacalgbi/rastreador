# Load the Rails application.
require_relative "application"
require Rails.root.join("app/jobs/send_command_job")

# Initialize the Rails application.
Rails.application.initialize!
