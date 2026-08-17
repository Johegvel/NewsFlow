Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#show'

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
        resources :saved_posts, only: [:create]
      end

      resources :reactions, only: [:destroy]
      resources :reports, only: [:index, :update]
      resources :saved_posts, only: [:destroy]
      resources :interests, only: [:index]

      resources :users, only: [] do
        resources :saved_posts, only: [:index]
      end

      get 'me/feed', to: 'feeds#show'
      get 'me/saved_posts', to: 'saved_posts#index'
      get 'me/interests', to: 'user_interests#show'
      patch 'me/interests', to: 'user_interests#update'
    end
  end
end