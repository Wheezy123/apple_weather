Rails.application.routes.draw do
  root 'weather_forecast#index'

  resources :weather_forecast, only: %i[index create]

  get 'up' => 'rails/health#show', as: :rails_health_check
end
