module StatusHelper
  def self.define_text(detail, status)
    return "Veículo hibernando" if status == 'offline' && detail.sleeping == true
    return "Veículo off-line" if status == 'offline'
    return "Veículo sem histórico. Você pode bloquear/desbloquear." if detail.nil?
    return "Em uso por #{detail.last_user}." if detail.rele_state == 'off'
    "Veículo disponível."
  end

  def self.define_state(detail)
    return "bloquear"    if detail.nil? # Se não tem evento, pode bloquear, porque, por padrão o rastreador iniciar desbloqueado
    return "desbloquear" if detail.rele_state == 'on' # Qualquer um pode desbloquear, porque o veículo está bloqueado e disponível para uso
    return "bloquear"    if detail.rele_state == 'off' && detail.last_user.present? # Se o relé está desligado e tem usuário
    return "not_user" # se chegar aqui, é porque o evento é desbloquear e o motorista é diferente
  end
end
