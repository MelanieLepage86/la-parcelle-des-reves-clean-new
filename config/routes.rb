Rails.application.routes.draw do
  namespace :admin, path: '/parmatouze1317' do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    get 'dashboard/new_image', to: 'dashboard#new_image', as: 'new_image'
    post 'dashboard/create_image', to: 'dashboard#create_image', as: 'create_image'
    get 'newsletter_subscribers', to: 'dashboard#newsletter_subscribers', as: 'newsletter_subscribers'
    resources :news_items

    resources :orders, only: [:index, :update, :destroy]

    resources :artworks, only: [] do
      patch :toggle_publish, on: :member
    end
  end

  devise_for :users
  root to: "pages#home"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Redirect admin path to login if needed
  get '/parmatouze1317', to: redirect('/users/sign_in')

  resources :artworks do
    collection do
      get :portfolio
      get :boutique
      get :prestations
    end
  end

  resources :orders, only: [:new, :create, :show, :destroy] do
    member do
      delete :cancel, to: 'orders#cancel'
    end
  end

  resources :contacts, only: [:new, :create]

  get '/page_daccueil', to: 'pages#accueil'
  get '/a_propos', to: 'pages#about'

  get '/connect_stripe', to: 'stripe#connect', as: :connect_stripe
  get '/stripe_dashboard', to: 'stripe#dashboard', as: :stripe_dashboard

  post '/add_to_cart', to: 'carts#add', as: :add_to_cart
  post 'remove_from_cart', to: 'carts#remove', as: 'remove_from_cart'

  get '/mentions', to: 'pages#mentions'

  resource :cart, only: [:show], path: '/panier' do
    get :checkout_info
    post :checkout_create_order
    get 'checkout_payment/:id', action: :checkout_payment, as: :checkout_payment
    get 'payment_intent/:id', to: 'carts#payment_intent', as: :payment_intent
  end

  resources :subscribers, only: [:create] do
    member do
      get :unsubscribe
    end
  end

  resources :newsletters, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      post :send_to_subscribers
      get :preview_email
    end
  end

  get '/artworks/:category/:sub_category', to: 'artworks#sub_category', as: 'artworks_category_sub_category'

  post "/webhooks/stripe", to: "webhooks#stripe"

  resources :news_items, only: [:index, :show]
end
