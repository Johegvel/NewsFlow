Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :communities, only: [:index, :show] do
        resources :posts, only: [:index, :create]
      end

      resources :posts, only: [:index, :show, :create] do
        resources :comments, only: [:index, :create]
        resources :reactions, only: [:index, :create]
        resources :reports, only: [:index, :create]
      end

      resources :reactions, only: [:destroy]
    end
  end
end