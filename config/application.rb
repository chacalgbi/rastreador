require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module Rastreador
  class Application < Rails::Application
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      raw Nokogiri::HTML.fragment(html_tag).child.add_class("is-invalid")
    end

    config.load_defaults 8.0
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :'pt-BR'
    config.autoload_lib(ignore: %w[assets tasks])
    config.eager_load_paths << Rails.root.join("app/jobs")

    config.solid_queue.recurring_tasks = [
      {
        class_name: "SearchStoppedMotorcyclesJob",
        command: "perform_later",
        schedule: "*/30 * * * *",
        args: []
      }
    ]
  end
end
