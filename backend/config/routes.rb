Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      get 'auth/me', to: 'auth#me'
      get 'auth/users', to: 'auth#users'

      resources :communities, only: [:index, :show] do
        resources :posts, only: [:index, :create]
      end

      resources :posts, only: [:index, :show, :create] do
        resources :comments, only: [:index, :create]
        resources :reactions, only: [:index, :create]
        resources :reports, only: [:index, :create]
      end
      
      resources :reports, only: [:index, :update]
      resources :reactions, only: [:destroy]

      resources :posts, only: [:index, :show, :create] do
        resources :saved_posts, only: [:create]
      end

      resources :users, only: [] do
        resources :saved_posts, only: [:index]
      end

      resources :saved_posts, only: [:destroy]
    end
  end
end