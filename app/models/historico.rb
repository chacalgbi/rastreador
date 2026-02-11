class Historico < ApplicationRecord
  MESES = %w[Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro].freeze

  validates :device_id, :tipo, :numero, :ano, presence: true
  validates :tipo, inclusion: { in: %w[semanal mensal] }
  validates :device_id, uniqueness: { scope: [:tipo, :numero, :ano] }

  scope :semanal, -> { where(tipo: 'semanal') }
  scope :mensal, -> { where(tipo: 'mensal') }
  scope :por_device, ->(device_id) { where(device_id: device_id) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id device_id tipo descricao numero ano odometro horimetro odometro_inicio horimetro_inicio observacao created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Atualiza os registros semanal e mensal para um device baseado nos valores cumulativos atuais.
  # odometro_km: valor cumulativo em km (Float)
  # horimetro_min: valor cumulativo em minutos (Float)
  def self.atualizar_historico(device_id, odometro_km, horimetro_min)
    hoje = Date.today
    atualizar_registro(device_id, 'semanal', hoje, odometro_km, horimetro_min)
    atualizar_registro(device_id, 'mensal', hoje, odometro_km, horimetro_min)
  end

  # Formata o horímetro de minutos para exibição "Xh YYm"
  def horimetro_formatado
    total_min = horimetro.to_f
    hours = (total_min / 60).to_i
    remaining = (total_min % 60).to_i
    "#{hours}h #{remaining.to_s.rjust(2, '0')}m"
  end

  # Formata o odômetro para exibição "X.XXkm"
  def odometro_formatado
    "#{odometro.to_f.round(2)}km"
  end

  private

  def self.atualizar_registro(device_id, tipo, data, odometro_km, horimetro_min)
    if tipo == 'semanal'
      numero = data.cweek
      ano = data.cwyear
      descricao = "Semana #{numero}/#{ano}"
    else
      numero = data.month
      ano = data.year
      descricao = "#{MESES[numero - 1]}/#{ano}"
    end

    registro = find_or_initialize_by(device_id: device_id, tipo: tipo, numero: numero, ano: ano)

    if registro.new_record?
      # Novo período: o valor inicial é o cumulativo atual, acumulado do período começa em 0
      registro.descricao = descricao
      registro.odometro_inicio = odometro_km
      registro.horimetro_inicio = horimetro_min
      registro.odometro = 0
      registro.horimetro = 0
    else
      # Período existente: calcula a diferença entre o cumulativo atual e o início do período
      registro.odometro = (odometro_km - registro.odometro_inicio).round(2)
      registro.horimetro = (horimetro_min - registro.horimetro_inicio).round(2)
    end

    registro.save!
    registro
  rescue StandardError => e
    Rails.logger.error("Historico.atualizar_registro | Error: #{e.message}")
    nil
  end
end
