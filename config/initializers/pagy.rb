# Configuração do Pagy para paginação
require 'pagy/extras/bootstrap'

# Configurações padrão do Pagy
Pagy::DEFAULT[:limit] = 100  # Número padrão de registros por página
Pagy::DEFAULT[:size] = 10   # Tamanho da paginação (quantos links mostrar)

# Configurações opcionais
# Pagy::DEFAULT[:limit_max] = 100  # Limite máximo de registros por página
# Pagy::DEFAULT[:limit_param] = :per_page  # Parâmetro para alterar limite via URL
# Pagy::DEFAULT[:limit_extra] = true  # Permite que o usuário altere o limite

# Para permitir que o usuário altere a quantidade de registros por página via URL
# Adicione esta configuração se quiser que o usuário possa usar ?per_page=30 na URL
# Pagy::DEFAULT[:limit_extra] = true
