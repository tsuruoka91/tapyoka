Rails.application.routes.draw do
  get 'home', to: 'home#index'
  get 'change_admin', to: 'home#change_admin'

  resources :tokens, only: [:index, :new, :create]
  resources :wallets, only: [:index, :create]
  root "home#index"

  resources :timestamps
  resources :transactions do
    collection do
      get :gift_new
      post :gift
      get :burn_new
      post :burn
    end
  end
  resources :users

  ActiveAdmin.routes(self)
end
