Rails.application.routes.draw do
  namespace :admin do
    resources :overviews, only: [:index]
    resources :legacy_service_names
    resources :uptime_checks, only: [:index, :create, :destroy]
    resources :services, only: [:index, :show, :create] do
      post '/unpublish/:publish_service_id/:deployment_environment',
        to: 'services#unpublish', as: :unpublish

      resources :versions, only: [:update, :edit, :show]
    end
    resources :users
    resources :publish_services

    root to: "overviews#index"
  end

  get '/health', to: 'health#show'
  get '/readiness', to: 'health#readiness'
  get '/metrics', to: 'metrics#show'

  # Auth0 routes
  get "/auth/auth0/callback" => "auth0#callback", as: 'auth0_callback'
  get "/auth/failure" => "auth0#failure"

  get '/signup_not_allowed' => 'user_sessions#signup_not_allowed', as: 'signup_not_allowed'
  get '/signup_error/:error_type' => 'user_sessions#signup_error', as: 'signup_error'
  resource :user_session, only: [:destroy]

  if Rails.env.development?
    post '/auth/developer/callback' => 'auth0#developer_callback'
  end

  resources :services, only: [:index, :edit, :update, :create] do
    member do
      resources :publish, only: [:index, :create]
      resources :pages, param: :page_uuid, only: [:create, :edit, :update, :destroy]
      resources :branches, param: :branch_uuid, only: [:create, :edit, :update, :destroy] do
        collection do
          get '/:previous_flow_uuid/new', to: 'branches#new', as: 'new'
        end
      end

      resources :settings, only: [:index]
      namespace :settings do
        resources :form_information, only: [:index, :create]

        resources :submission, only: [:index] do
          collection do
            resources :email, only: [:index, :create]
          end
        end
      end

      mount MetadataPresenter::Engine => '/preview', as: :preview
    end
  end

  namespace :api do
    resources :services do
      resources :flow, param: :uuid, only: [] do
        resources :destinations, only: [:new, :create]
      end

      resources :pages, only: [:show] do
        get '/destroy-message', to: 'pages#destroy_message', as: :destroy_message

        resources :questions, only: [] do
          get '/destroy-message', to: 'questions#destroy_message', as: :destroy_message
        end
      end

      resources :branches, param: :previous_flow_uuid do
        get '/conditionals/:conditional_index', to: 'branches#new_conditional'
        get '/destroy-message', to: 'branches#destroy_message', as: :destroy_message
      end

      get '/components/:component_id/conditionals/:conditional_index/expressions/:expression_index', to: 'expressions#show'
    end
  end

  root to: 'home#show'
end
