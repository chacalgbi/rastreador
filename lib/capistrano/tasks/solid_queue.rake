namespace :solid_queue do
  desc "Start Solid Queue in the background"
  task :start do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          # roda em background e joga o log pra shared/log
          execute :nohup, "/home/deploy/.rbenv/shims/bundle exec #{current_path}/bin/jobs >> #{shared_path}/log/solid_queue.log 2>&1 &"
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
      execute "pgrep -f bin/jobs && echo 'SolidQueue is running' || echo 'SolidQueue is not running'"
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
