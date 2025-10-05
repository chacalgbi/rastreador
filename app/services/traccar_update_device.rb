class TraccarUpdateDevice
  def initialize(standardized_data, detail)
    @params = standardized_data
    @detail = detail
  end

  def update
    update_detail
    update_view
    update_admin_view
    recover_level_battery if criteria_for_obtaining_battery_voltage
  end

  private

  def update_detail
    # Filtra os parâmetros para remover aqueles que têm valores vazios
    params = ActionController::Parameters.new(@params)

    filtered_params = params.permit(
      :device_name, :model, :ignition, :rele_state, :last_event_type, :last_user, :last_rele_modified, :url, :velo_max,
      :battery, :bat_bck, :horimetro, :odometro, :cercas, :satelites, :version, :imei, :bat_nivel, :signal_gps,
      :signal_gsm, :acc, :acc_virtual, :charge, :heartbeat, :obs, :status, :network, :params, :apn, :ip_and_port, :iccid
    ).to_h.reject { |_, v| v.blank? }

    @changed_fields = detect_changed_fields(filtered_params)
    @status_changed = filtered_params.key?('status') && @detail.status != filtered_params['status']

    @detail.update(filtered_params)
  end

  def update_view
    Turbo::StreamsChannel.broadcast_action_to(
      "home_stream",
      action: "replace",
      target: "detail_#{@detail.device_id}",
      partial: "details/detail",
      locals: { detail: @detail }
    )

    # Só desbloqueia o botão de (Ligar/desligar relé) se o dispositivo estiver online, pois se entrar nesse método
    # é porque o dispositivo está online e respondeu ao callBack
    Turbo::StreamsChannel.broadcast_render_to(
      "home_stream",
      partial: "shared/enable_button",
      locals: { device_id: @detail.device_id }
    )

    # Destaca campos que mudaram
    if @changed_fields.any?
      Turbo::StreamsChannel.broadcast_render_to(
        "home_stream",
        partial: "shared/highlight_changes",
        locals: { device_id: @detail.device_id, changed_fields: @changed_fields }
      )
    end

    # Atualiza a view quando o status mudar
    update_status_view if @status_changed
  end

  def update_admin_view
    Turbo::StreamsChannel.broadcast_action_to(
      "admin_detail_stream",
      action: "replace",
      target: "admin_detail_stream_div",
      partial: "details/detail_admin",
      locals: { detail: @detail }
    )
  end

  def detect_changed_fields(new_params)
    monitored_fields = %w[
      signal_gps signal_gsm odometro horimetro ignition
      battery bat_bck network bat_nivel charge acc
    ]

    changed = []

    monitored_fields.each do |field|
      if new_params.key?(field)
        current_value = @detail.send(field).to_s
        new_value = new_params[field].to_s

        if current_value != new_value
          changed << field
        end
      end
    end

    changed
  end

  def recover_level_battery
    command = Command.find_by(type_device: @detail.model, name: 'Status')
    send_command = command.present? ? command.command : nil
    return if send_command.nil?
    send_command = send_command.gsub('XXXX', @detail.imei) if @detail.model == 'st8310u'

    Traccar.command(@detail.device_id, send_command)
  end

  def criteria_for_obtaining_battery_voltage
    # Caso receba um alarme de 'bateria baixa', 'corte de energia', 'carro em movimento' ou 'carro parado'.
    # Enviar um comando para recuperar e guardar o valor da bateria do carro e da bateria de backUp.
    # Isso serve para alimentar o gráfico e saber se a bateria não está segurando carga.
    @params&.[](:alarme_type) == 'lowBattery' ||
    @params&.[](:alarme_type) == 'powerCut' ||
    @params&.[](:last_event_type) == 'deviceStopped'
  end

  def update_status_view

    # Para deixar o botão disponível para uso, é necessário que o dispositivo esteja online e responda a um comando
    SendCommandJob.perform_later({device_id: @detail.device_id, command: 'STATUS#'}) if @detail.status == 'online'

    # Atualiza o badge de status no card principal (_car.html.erb)
    Turbo::StreamsChannel.broadcast_action_to(
      "home_stream",
      action: "replace",
      target: "status_badge_#{@detail.device_id}",
      partial: "home/status_badge",
      locals: { detail: @detail }
    )

    # Atualiza o conteúdo de detalhes se estiver aberto (_details.html.erb e _btn_bloquear_desbloquear.html.erb)
    msg = StatusHelper.define_text(@detail, @detail.status)
    state = StatusHelper.define_state(@detail)

    Turbo::StreamsChannel.broadcast_action_to(
      "home_stream",
      action: "replace",
      target: "details_status_content_#{@detail.device_id}",
      partial: "home/details_status_content",
      locals: {
        device_id: @detail.device_id,
        status: @detail.status,
        msg: msg,
        info: @detail,
        state: state
      }
    )
  end
end
