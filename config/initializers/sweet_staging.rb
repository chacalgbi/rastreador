SweetStaging.setup do |config|
  config.enabled = true
  config.fetch_timeout = 3000
  config.console = true

  log_base_path = Rails.root.join("log")

  config.logs = [
    {
      name: "production.log",
      path: "log/production.log"
    },
    {
      name: "solid_queue_detailed.log",
      path: "log/solid_queue_detailed.log"
    },
    {
      name: "solid_queue.log",
      path: "log/solid_queue.log"
    },
    {
      name: "solid_queue_monitor.log",
      path: "log/solid_queue_monitor.log"
    }
  ]
  config.commands = [
    {
      name: "Proc Solid Queue",
      command: "ps aux | grep -i solid-queue"
    },
    {
      name: "Proc Nginx",
      command: "ps aux | grep -i nginx"
    },
    {
      name: "Proc Passenger",
      command: "ps aux | grep -i passenger"
    },
    {
      name: "Proc Ruby/Rails",
      command: "ps aux | grep -i ruby"
    },
    {
      name: "Passenger Status",
      command: "passenger-status 2>/dev/null || echo 'Passenger não está rodando ou comando não disponível'"
    },
    {
      name: "Nginx Status",
      command: "systemctl status nginx --no-pager -l 2>/dev/null || service nginx status 2>/dev/null || echo 'Nginx status não disponível'"
    },
    {
      name: "Top Processos (CPU/Mem)",
      command: "ps aux --sort=-%mem | head -n 20"
    },
    {
      name: "Uso de Memória",
      command: "free -m"
    },
    {
      name: "Uso de Disco",
      command: "df -h | grep -v tmpfs"
    },
    {
      name: "Uptime do Servidor",
      command: "uptime"
    },
    {
      name: "Carga do Sistema (Load Average)",
      command: "cat /proc/loadavg"
    },
    {
      name: "Conexões de Rede Ativas",
      command: "netstat -an | grep ESTABLISHED | wc -l"
    },
    {
      name: "Portas em Uso",
      command: "netstat -tlnp 2>/dev/null | grep LISTEN || ss -tlnp | grep LISTEN"
    },
    {
      name: "Últimos Logins",
      command: "last -n 10"
    },
    {
      name: "Espaço em Logs",
      command: "du -sh #{log_base_path}/* 2>/dev/null | sort -h"
    }
  ]

  config.http_basic_authentication_enabled   = true
  config.http_basic_authentication_user_name = ENV['JOB_USER']
  config.http_basic_authentication_password  = ENV['JOB_PASS']

end if defined?(SweetStaging)
