class SendMonthlyKmWhatsappJob < ApplicationJob
  queue_as :monthly_km_whatsapp

  RETRY_WAIT_ON_FAILURE = 1.hour

  # Para testar essa classe, você pode executar o seguinte comando no console do Rails:
  # SendMonthlyKmWhatsappJob.perform_now
  # No terminal: RAILS_ENV=production bundle exec rails runner 'SendMonthlyKmWhatsappJob.perform_now'

  # Para agendar a execução recorrente, você pode usar o seguinte comando no console do Rails:
  # SendMonthlyKmWhatsappJob.start_recurring

  def perform
    @failed = false
    @sent_summaries = {}
    mes_ref = 1.month.ago.to_date

    Rails.logger.info("SendMonthlyKmWhatsappJob.perform")
    SaveLog.new('monthly_km_whatsapp', "Iniciando envio do resumo mensal de km (#{format('%02d', mes_ref.month)}/#{mes_ref.year}).").save

    Notification.where.not(whatsapp: [nil, '']).find_each do |notification|
      send_monthly_summary(notification, mes_ref)
    end

    SaveLog.new('monthly_km_whatsapp', "Envio do resumo mensal de km (#{format('%02d', mes_ref.month)}/#{mes_ref.year}) finalizado.").save
  rescue StandardError => e
    @failed = true
    error_message = "SendMonthlyKmWhatsappJob.perform | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
    Rails.logger.error("#{error_message}\n")
    SaveLog.new('error', error_message).save
  ensure
    reschedule!
  end

  # Agenda a primeira execução para o próximo dia 01 às 08:00 (horário de Brasília).
  def self.start_recurring
    connection = SolidQueue::Job.connection
    lock_acquired = connection.select_value("SELECT GET_LOCK('send_monthly_km_whatsapp_schedule', 10)").to_i == 1
    return unless lock_acquired

    target = next_run_time
    scheduled_jobs = SolidQueue::Job.where(class_name: name, finished_at: nil)
                                    .where(scheduled_at: (target - 1.minute)..(target + 1.minute))
                                    .order(:scheduled_at, :id)

    scheduled_jobs.offset(1).destroy_all
    set(wait_until: target).perform_later unless scheduled_jobs.exists?
  ensure
    connection.select_value("SELECT RELEASE_LOCK('send_monthly_km_whatsapp_schedule')") if lock_acquired
  end

  # Próximo dia 01 às 08:00 no fuso da aplicação (America/Sao_Paulo).
  def self.next_run_time(from = Time.zone.now)
    candidate = from.change(day: 1, hour: 8, min: 0, sec: 0, usec: 0)
    candidate = candidate.next_month.change(day: 1, hour: 8, min: 0, sec: 0, usec: 0) if candidate <= from
    candidate
  end

  private

  def reschedule!
    if @failed
      self.class.set(wait: RETRY_WAIT_ON_FAILURE).perform_later
    else
      self.class.start_recurring
    end
  end

  def send_monthly_summary(notification, mes_ref)
    user = User.find_by(id: notification.user_id)
    return if user.nil? || user.cars.blank?

    device_ids = user.cars.split(',').map(&:strip).reject(&:blank?).uniq
    return if device_ids.empty?

    historicos = Historico.where(device_id: device_ids, tipo: 'mensal', numero: mes_ref.month, ano: mes_ref.year)
                          .index_by(&:device_id)
    details = Detail.where(device_id: device_ids).index_by(&:device_id)

    device_ids.each do |device_id|
      historico = historicos[device_id]
      next if historico.nil? || historico.odometro.to_f <= 0

      recipient = notification.whatsapp.to_s.gsub(/\D/, '')
      delivery_key = [user.id, recipient, device_id]
      next if @sent_summaries[delivery_key]

      vehicle_name = details[device_id]&.device_name.presence || "ID #{device_id}"
      Notify.whatsapp(notification.whatsapp, build_message(user, vehicle_name, historico.odometro, mes_ref))
      @sent_summaries[delivery_key] = true
    end
  end

  def build_message(user, vehicle_name, odometro, mes_ref)
    km = odometro.to_f.round(2)
    km = km.truncate == km ? km.to_i : km
    month_name = Historico::MESES[mes_ref.month - 1]

    <<~MSG
      Olá *#{user.name}*! 👋🚗

      No mês de *#{month_name}/#{mes_ref.year}* seu veículo *#{vehicle_name}* rodou *#{km} km*. 📊✨

      Não se esqueça de acessar regularmente seu aplicativo e ficar familiarizado com ele. Qualquer dúvida entre em contato com o suporte.

      Tenha um ótimo mês! 🛣️😊
    MSG
  end

end
