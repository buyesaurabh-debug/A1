Rails.application.routes.draw do
  devise_for :users

  root to: "dashboard#index"

  get 'dashboard', to: 'dashboard#index'
  get 'friends/:id', to: 'friends#show', as: :friend

  resources :groups do
    member do
      post :add_member
      delete :remove_member
    end
    resources :expenses
    resources :settlements, only: [:new, :create]
  end
end
