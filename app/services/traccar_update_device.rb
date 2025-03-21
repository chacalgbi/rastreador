class TraccarUpdateDevice
  def initialize(standardized_data, detail)
    @params = standardized_data
    @detail = detail
  end

  def update
    update_detail
    update_view
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
  end
end
