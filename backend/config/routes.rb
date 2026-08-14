Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      namespace :auth do
        post "register", to: "registrations#create"
        post "login", to: "sessions#create"
        get "me", to: "sessions#me"
      end

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

      get "me/feed", to: "feeds#show"
      get "me/saved_posts", to: "saved_posts#index"
      get "me/interests", to: "user_interests#show"
      patch "me/interests", to: "user_interests#update"
    end
  end
end