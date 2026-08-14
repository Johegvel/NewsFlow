Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "register", to: "registrations#create"
        post "login", to: "sessions#create"
        get "me", to: "sessions#me"
      end
      
      get "health", to: "health#show"

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

        resource :interests,
                 only: [:show, :update],
                 controller: "user_interests"

        get "feed", to: "feeds#show"
      end
    end
  end
end