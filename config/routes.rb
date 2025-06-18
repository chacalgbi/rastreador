Rails.application.routes.draw do
  namespace :admin do
    get    '/',        to: 'home#index'
    get    'sign_in',  to: 'sessions#new'
    post   'sign_in',  to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    resources :users
    resources :details
    post 'details/rele'
    post 'details/send_command'
    post 'commands/send_command'
    resources :events
    resources :commands
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
  resources :driver, only: [:index, :edit, :update, :destroy] do
    collection do
      get :cars
      post :cars_update
    end
  end
  resources :details, only: [:index] do
    member do
      get :edit_settings
      patch :update_settings
    end
  end
  resources :passwords, param: :token
  get "home/index"
  get "home/location"
  get "home/details"
  get "home/hide_details"
  post "home/last_events"
  post "home/block_and_desblock"
  post "event/webhook_traccar"
  resources :registrations, only: [:new, :create]
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
