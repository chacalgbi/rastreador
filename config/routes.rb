Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "home/index"
  get "home/location"
  get "home/details"
  get "home/hide_details"
  post "home/last_events"
  post "home/block_and_desblock"
  resources :registrations, only: [:new, :create]
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
