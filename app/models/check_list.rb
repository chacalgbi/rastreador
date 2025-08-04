class CheckList < ApplicationRecord
  self.inheritance_column = nil  # Desabilita STI para usar a coluna 'type'

  validates :user_id, presence: true
  validates :detail_id, presence: true
  validates :type, presence: true

  # Associações
  def user
    User.find_by(id: user_id)
  end

  def detail
    Detail.find_by(device_id: detail_id)
  end

  # Métodos auxiliares
  def driver_name
    user&.name || "Usuário não encontrado"
  end

  def car_name
    detail&.device_name || "Veículo não encontrado"
  end

  def has_issues?
    obs.present?
  end

  def checked_items_count
    boolean_fields = %w[freios luzes pneus estepe oleo buzina painel doc retrovisor parabrisa limpador macaco lataria]
    boolean_fields.count { |field| send(field) }
  end

  def total_items_count
    13
  end

  def completion_percentage
    ((checked_items_count.to_f / total_items_count) * 100).round(1)
  end

  def unchecked_items
    field_names = {
      'freios' => 'Freios',
      'luzes' => 'Luzes/Giroflex',
      'pneus' => 'Pneus',
      'estepe' => 'Estepe/Calotas',
      'oleo' => 'Óleo/Água/Óleo do motor',
      'buzina' => 'Buzina',
      'painel' => 'Painel',
      'doc' => 'Documentos',
      'retrovisor' => 'Vidros/Retrovisores/Maçanetas',
      'parabrisa' => 'Para-brisa',
      'limpador' => 'Limpador',
      'macaco' => 'Chave de rodas/Macaco/Triângulo',
      'lataria' => 'Lataria/Para-choques'
    }

    unchecked = []
    field_names.each do |field, name|
      unchecked << name unless send(field)
    end

    unchecked
  end

  def unchecked_items_text
    items = unchecked_items
    return "" if items.empty?
    "(#{items.join(', ')})"
  end
end
