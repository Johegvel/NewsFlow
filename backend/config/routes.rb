Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :communities, only: [:index, :show] do
        resources :posts, only: [:index, :create]
      end

      resources :posts, only: [:index, :show, :create]
    end
  end
end