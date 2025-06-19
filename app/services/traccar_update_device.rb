class TraccarUpdateDevice
  def initialize(standardized_data, detail)
    @params = standardized_data
    @detail = detail
  end

  def update
    update_detail
    update_view
    update_admin_view
  end

  private

  def update_detail
    # Filtra os parâmetros para remover aqueles que têm valores vazios
    params = ActionController::Parameters.new(@params)

    filtered_params = params.permit(
      :device_name, :model, :ignition, :rele_state, :last_event_type, :last_user, :last_rele_modified, :url, :velo_max,
      :battery, :bat_bck, :horimetro, :odometro, :cercas, :satelites, :version, :imei, :bat_nivel, :signal_gps,
      :signal_gsm, :acc, :acc_virtual, :charge, :heartbeat, :obs, :status, :network, :params, :apn, :ip_and_port
    ).to_h.reject { |_, v| v.blank? }

    @changed_fields = detect_changed_fields(filtered_params)

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
end
