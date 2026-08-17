# Relatorio de incidente - 2026-06-09

## Contexto
- Servidor com 2 aplicacoes atras do mesmo Nginx:
  - Traccar (Java): https://cte.rastreadoresbahia.com.br/
  - Rastreador (Rails): https://app.cte.rastreadoresbahia.com.br/
- Sintoma inicial: app Rails indisponivel e navegador mostrando pagina nao exibida.

## Sintomas observados
- Nginx com queda de workers em loop:
  - worker process exited on signal 11 (core dumped)
- Kernel registrando segfault recorrente no processo nginx.
- Em alguns momentos o Traccar seguia funcionando, mas a app Rails falhava.
- Ao abrir detalhes de veiculos, ocorria ERR_EMPTY_RESPONSE no frontend.

## Diagnostico feito
1. Validacao basica da config:
	- nginx -t retornava OK (nao era erro de sintaxe).
2. Isolamento por vhost/modulo:
	- Bloco da app com Passenger foi desativado temporariamente para teste.
	- Segfault reduziu/alterou comportamento, indicando gatilho no caminho Rails/Passenger/modulos.
3. Banco de dados:
	- Rails em production conectou no MySQL com sucesso (SELECT 1).
	- Ou seja, causa principal nao era DB parado.
4. Modulos dinamicos:
	- Passenger foi atualizado e testado.
	- Nchan foi identificado como ativo (modules-enabled/50-mod-nchan.conf).
	- Ainda houve segfault em cenarios especificos.
5. Mitigacao definitiva de estabilidade:
	- Nginx colocado em modo minimo (sem modulos dinamicos de terceiros).
	- App Rails migrada para Puma com reverse proxy no Nginx.

## Causa raiz pratica
- Incompatibilidade/instabilidade em modulo(s) dinamico(s) carregado(s) no Nginx, causando segfault de worker sob determinadas requisicoes.
- Passenger participou do caminho de falha inicial.
- Nchan foi confirmado como modulo ativo no ambiente durante o incidente.

## O que foi feito para resolver
1. Backup da configuracao Nginx.
2. Desativacao de Passenger no Nginx para a app Rails.
3. Atualizacao/reinstalacao de Passenger:
	- passenger
	- libnginx-mod-http-passenger
4. Ajuste de chave GPG do repositorio Passenger.
5. Mudanca de estrategia de execucao da app Rails:
	- Subir com Puma em 127.0.0.1:3000.
	- Nginx como reverse proxy para app.cte.
6. Desativacao de modulos dinamicos que poderiam causar segfault (incluindo Nchan).
7. Validacao final:
	- Sem novos segfaults no journal.
	- Traccar e app Rails atendendo normalmente.

## Estado final adotado
- Nginx minimalista e estavel.
- Rails servida por Puma (proxy no Nginx), sem Passenger em producao.
- Recomendacao: manter assim enquanto estabilidade estiver OK.

## Risco operacional remanescente
- Se Puma estiver apenas via nohup, pode nao subir automaticamente apos reboot/deploy.
- Recomendado usar systemd para gerenciar Puma (enable + restart automatico).

## Comandos de verificacao rapida (runbook)
### 1) Saude do Nginx
sudo nginx -t
sudo systemctl status nginx --no-pager
sudo journalctl -k --since "5 minutes ago" --no-pager | grep -Ei "nginx|segfault" || echo "sem segfault"

### 2) Saude do Puma
ss -tlnp | grep 3000
sudo systemctl status rastreador-puma --no-pager

### 3) Teste dos dominios
curl -Ik https://cte.rastreadoresbahia.com.br/
curl -Ik https://app.cte.rastreadoresbahia.com.br/

### 4) Logs uteis
sudo tail -n 100 /var/log/nginx/error.log
sudo journalctl -u nginx -n 100 --no-pager
sudo journalctl -u rastreador-puma -n 100 --no-pager
tail -n 100 /home/deploy/rastreador/current/log/production.log

## Checklist de logs (apos migracao Passenger -> Puma)
Objetivo: confirmar para onde estao indo logs de requisicao e erros apos trocar servidor de app.

### A) Logs da aplicacao Rails
- Verificar se o arquivo de producao esta recebendo eventos:
tail -n 50 /home/deploy/rastreador/current/log/production.log
- Gerar uma requisicao na app e confirmar nova linha no arquivo.

### B) Logs do Puma (processo de app server)
- Se estiver em systemd:
sudo journalctl -u rastreador-puma -n 100 --no-pager
sudo journalctl -u rastreador-puma -f
- Se estiver em nohup:
tail -n 100 /home/deploy/rastreador/current/log/puma.log

### C) Logs do Nginx (proxy/web)
- Erros do Nginx:
sudo tail -n 100 /var/log/nginx/error.log
- Requisicoes no access log:
sudo tail -n 100 /var/log/nginx/access.log

### D) Conferencia cruzada (fim-a-fim)
1. Executar uma chamada de teste:
curl -Ik https://app.cte.rastreadoresbahia.com.br/
2. Conferir se aparece no access.log do Nginx.
3. Conferir se aparece evento correspondente no production.log (ou endpoint que gere log).

### E) Sinais de problema apos migracao
- Nginx responde 502/504: Puma parado, porta errada ou timeout de proxy.
- Sem logs no production.log: logger da app ou permissao de escrita incorreta.
- Sem logs no journal do servico: Puma pode estar rodando fora do systemd.

### F) Comandos de acao rapida
- Reiniciar Puma:
sudo systemctl restart rastreador-puma
- Ver status Puma:
sudo systemctl status rastreador-puma --no-pager
- Testar porta local Puma:
ss -tlnp | grep 3000

## Como repetir o procedimento em novo incidente
1. Confirmar se ha segfault no kernel/journal.
2. Garantir que Passenger e Nchan estejam desativados (se estiver usando modo estavel atual).
3. Confirmar Puma ativo na porta 3000.
4. Validar proxy do Nginx para app.cte.
5. Testar endpoint problematico (ex.: detalhes de veiculo).

## Prompt sugerido para proxima emergencia
"Tenho um servidor com Nginx na frente de Traccar (Java) e Rails. Ja tivemos incidente de segfault de worker Nginx (signal 11), resolvido desativando modulos dinamicos e usando Rails via Puma em 127.0.0.1:3000 com proxy no Nginx. Quero diagnosticar rapidamente se houve regressao. Considere este contexto e me passe verificacoes e comandos de recuperacao sem downtime desnecessario."

