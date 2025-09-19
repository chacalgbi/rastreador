Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"
  resources :notifications
  namespace :admin do
    get    '/',        to: 'details#index'
    get    'sign_in',  to: 'sessions#new'
    post   'sign_in',  to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    resources :users
    resources :details
    post 'details/rele'
    post 'details/send_command'
    post 'commands/send_command'
    post 'commands/send_command_to_all'
    post 'commands/send_command_sms'
    resources :events
    resources :commands
    resources :batteries
    resources :notifications
    resource  :password_reset

    resources :logs, only: [:index] do
      collection do
        get ':directory', to: 'logs#show_directory', as: 'directory', constraints: { directory: /carros|informacao/ }
        get ':directory/:filename', to: 'logs#show_log', as: 'log_file', constraints: { directory: /carros|informacao/, filename: /.+\.log/ }
        delete ":directory/:filename", to: "logs#clear_log", as: "clear_log_file", constraints: { directory: /carros|informacao/, filename: /.+\.log/ }
      end
    end
  end
  resource :session
  resources :driver, only: [:index, :edit, :update, :destroy, :new, :create] do
    collection do
      get :cars
      post :cars_update
    end
    member do
      get :edit_password
      patch :update_password
    end
  end
  resources :details, only: [:index] do
    member do
      get :edit_settings
      patch :update_settings
    end
  end
  resources :check_lists, only: [:index]
  resources :passwords, only: [:new, :create]
  get 'passwords/edit', to: 'passwords#edit', as: :edit_password
  patch 'passwords/update', to: 'passwords#update', as: :update_password
  get "home/index"
  get "home/location"
  get "home/details"
  get "home/hide_details"
  get "home/battery_history"
  post "home/battery_history"
  post "home/last_events"
  post "home/odometro"
  post "home/block_and_desblock"
  post "event/webhook_traccar"
  # resources :registrations, only: [:new, :create] # Removido para desabilitar auto-registro
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
