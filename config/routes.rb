Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for authentication
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  # API routes
  namespace :api do
    namespace :v1 do
      # Current user
      resource :me, only: [:show, :update], controller: 'me'

      # Core resources
      resources :categories, only: [:index, :show, :create, :update, :destroy]

      # User profiles (onboarding completion)
      resources :user_profiles, only: [] do
        collection do
          post :complete
        end
      end
      resources :addresses, only: [:index, :show, :create, :update, :destroy]

      # User profiles
      resources :tasker_profiles, only: [:index, :show, :create, :update, :destroy] do
        collection do
          post :onboarding
        end
      end

      # Tasks and bidding
      resources :tasks, only: [:index, :show, :create, :update, :destroy] do
        resources :bids, only: [:index, :create], shallow: true
      end

      resources :bids, only: [:show, :update, :destroy] do
        member do
          post :accept
          post :withdraw
        end
      end

      # Direct requests
      resources :direct_requests, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :accept
          post :reject
          post :counter_offer
        end
      end

      # Tasker availability
      resources :tasker_availabilities, only: [:index, :show, :create, :update, :destroy]

      # Transactions
      resources :transactions, only: [:index, :show, :create]

      # Reviews and ratings
      resources :reviews, only: [:index, :show, :create, :update, :destroy]

      # Messaging
      resources :messages, only: [:index, :show, :create] do
        collection do
          get :conversations
          post :mark_all_as_read
        end
        member do
          post :mark_as_read
        end
      end

      # Notifications
      resources :notifications, only: [:index, :show] do
        collection do
          post :mark_all_as_read
        end
        member do
          post :mark_as_read
        end
      end

      # Favorites
      resources :favorites, only: [:index, :create, :destroy]

      # Portfolio
      resources :portfolio_items, only: [:index, :show, :create, :update, :destroy]

      # Disputes
      resources :disputes, only: [:index, :show, :create, :update] do
        member do
          post :resolve
        end
      end

      # GDPR Compliance
      resources :gdpr_consents, only: [:index, :create] do
        member do
          post :withdraw
        end
      end

      resources :data_deletion_requests, only: [:index, :show, :create] do
        member do
          post :process
          post :complete
        end
      end

      resources :audit_logs, only: [:index, :show]
      resources :data_breach_logs, only: [:index, :show, :create, :update]
      resources :encryption_keys, only: [:index, :show, :create, :update]
      resources :data_processing_agreements, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
