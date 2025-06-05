namespace :solid_queue do
  desc "Start Solid Queue in the background"
  task :start do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          # roda em background e joga o log pra shared/log
          # execute :nohup, "/home/deploy/.rbenv/shims/bundle exec rails runner \'SolidQueue::Supervisor.start\' >> #{shared_path}/log/solid_queue.log 2>&1 &"
          execute :echo, "'--- Testando carregamento de SendCommandJob ---'; /home/deploy/.rbenv/shims/bundle exec rails runner \"puts 'SendCommandJob carregado com sucesso' if defined?(SendCommandJob); puts 'SendCommandJob NÃO encontrado' unless defined?(SendCommandJob)\" >> #{shared_path}/log/capistrano_test.log 2>&1"
        end
      end
    end
  end

  desc "Stop Solid Queue"
  task :stop do
    on roles(:app) do
      # mata qualquer processo bin/jobs
      execute :pkill, "-f bin/jobs || true"
    end
  end

  desc "Restart Solid Queue"
  task :restart do
    on roles(:app) do
      invoke "solid_queue:stop"
      invoke "solid_queue:start"
    end
  end
end

# Hooks para rodar após cada deploy
after "deploy:published", "solid_queue:restart"
