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
    filtered_params = @params.permit(
      :device_id, :battery, :bat_bck, :bat_nivel, :satelite, :signal_gps, :signal_gsm,
      :cercas, :acc, :acc_virtual, :rele, :charge, :horimetro, :odometro, :heartbeat,
      :url, :velo_max
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
