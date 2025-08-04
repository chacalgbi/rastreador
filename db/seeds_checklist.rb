# Script para gerar 70 registros faker de CheckList
# Baseado no último registro existente

puts "Iniciando criação de 70 registros faker de CheckList..."

# Pegar o último registro como base
last_record = CheckList.last
puts "Último registro encontrado: ID #{last_record.id}"
puts "user_id: #{last_record.user_id}, detail_id: #{last_record.detail_id}"

# Arrays de observações variadas para tornar os dados mais realísticos
observacoes = [
  "Tá uma bagunça. buzina sem funcionar, documento atrasado.",
  "Freios rangendo, precisa revisar urgente.",
  "Luzes do painel queimadas, verificar fusíveis.",
  "Pneu furado, estepe também está baixo.",
  "Óleo muito escuro, trocar na próxima revisão.",
  "Para-brisa trincado no canto direito.",
  "Limpador não funciona direito, borracha gasta.",
  "Macaco enferrujado, difícil de usar.",
  "Lataria riscada na lateral esquerda.",
  "Retrovisor esquerdo solto, precisa apertar.",
  "Documentos em ordem, veículo ok.",
  "Buzina fraca, quase não funciona.",
  "Freios e luzes ok, mas pneus carecas.",
  "",  # Alguns registros sem observação
  "",
  "",
  "Problema no painel, velocímetro não marca.",
  "Estepe sem ar, precisa calibrar.",
  "Limpador fazendo barulho estranho.",
  "Óleo no nível, mas filtro sujo."
]

# Tipos de ação
tipos = ['bloquear', 'desbloquear']

# Campos booleanos do checklist
campos_checklist = [:freios, :luzes, :pneus, :estepe, :oleo, :buzina, :painel, :doc, :retrovisor, :parabrisa, :limpador, :macaco, :lataria]

# Criar 70 registros
70.times do |i|
  # Gerar valores aleatórios para os campos booleanos (70-90% de chance de ser true)
  checklist_data = {}
  campos_checklist.each do |campo|
    checklist_data[campo] = rand(1..10) <= 8  # 80% de chance de ser true
  end

  # Escolher observação aleatória
  obs_aleatoria = observacoes.sample

  # Definir se tem problemas (se algum campo é false ou se tem observação)
  tem_problemas = checklist_data.values.include?(false) || obs_aleatoria.present?

  # Criar datas variadas nos últimos 30 dias
  data_criacao = rand(30.days.ago..Time.current)

  # Criar o registro
  CheckList.create!(
    user_id: last_record.user_id,
    detail_id: last_record.detail_id,
    type: tipos.sample,
    **checklist_data,
    obs: obs_aleatoria,
    created_at: data_criacao,
    updated_at: data_criacao
  )

  print "." if (i + 1) % 10 == 0  # Progresso a cada 10 registros
end

puts "\n✅ 70 registros faker criados com sucesso!"
puts "Total de registros na tabela: #{CheckList.count}"
puts "Registros com problemas: #{CheckList.where.not(obs: [nil, '']).count}"
puts "Registros de bloqueio: #{CheckList.where(type: 'bloquear').count}"
puts "Registros de desbloqueio: #{CheckList.where(type: 'desbloquear').count}"
