Rails.application.config.after_initialize do
  begin
    if ActiveRecord::Base.connection.table_exists?('notifications')
      NotificationCacheService.load_notifications
    else
      Rails.logger.warn "Tabela notifications não existe ainda. Cache será carregado após migration."
    end
  rescue => e
    Rails.logger.error "Erro ao carregar cache de notificações: #{e.message}"
  end
end
