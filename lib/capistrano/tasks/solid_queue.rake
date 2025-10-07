namespace :solid_queue do
  desc "Start Solid Queue in the background"
  task :start do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          # roda em background e joga o log pra shared/log
          execute :nohup, "/home/deploy/.rbenv/shims/bundle exec #{current_path}/bin/jobs >> #{shared_path}/log/solid_queue.log 2>&1 &"
          execute "sleep 15"
          execute "ps aux | grep -i solid-queue || true"
        end
      end

      within current_path do
        with rails_env: fetch(:rails_env) do
          execute "cd #{current_path} && /home/deploy/.rbenv/shims/bundle exec rails runner 'SearchStoppedMotorcyclesJob.start_recurring'"
        end
      end
    end
  end

  desc "Stop Solid Queue"
  task :stop do
    on roles(:app) do
      execute "ps aux | grep -i solid-queue || true"
      execute "sleep 3"
      execute "pkill -9 -f solid-queue || true"
      execute "sleep 4"
    end
  end

  desc "Check if Solid Queue is running"
  task :status do
    on roles(:app) do
      execute "echo 'Processos Solid Queue:'"
      execute "pgrep -f solid-queue | wc -l | xargs echo 'Número de processos:'"
      execute "ps aux | grep -v grep | grep solid-queue || echo 'Nenhum processo encontrado'"
    end
  end

  desc "Restart Solid Queue"
  task :restart do
    on roles(:app) do
      invoke "solid_queue:stop"
      invoke "solid_queue:start"
    end
  end

  desc "Create deploy event in RailsPerformance"
  task :create_deploy_event do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute "cd #{current_path} && /home/deploy/.rbenv/shims/bundle exec rails runner 'RailsPerformance.create_event(name: \"Deploy\", options: { borderColor: \"#00E396\", label: { borderColor: \"#00E396\", orientation: \"horizontal\", text: \"Deploy\" } })'"
        end
      end
    end
  end
end

# Hooks para rodar após cada deploy
after "deploy:published", "solid_queue:restart"
after "solid_queue:restart", "solid_queue:create_deploy_event"
