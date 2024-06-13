Rails.application.routes.draw do
  get 'home', to: 'home#index'
  resources :tokens, only: [:index, :new, :create] do
    collection do
      get :transfer, to: 'tokens#new'
      post :transfer
      get :burn_select
      post :burn
    end
  end
  resources :wallets, only: [:index, :create]
  root "home#index"

  resources :timestamps
  resources :transactions
  resources :users

  ActiveAdmin.routes(self)
end
