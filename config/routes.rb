Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :shipments, only: [:index]

  resources :companies, only: [] do
    resources :shipments, only: [:show] do
      get 'tracking', on: :member
      post 'search', on: :collection
    end
  end
end
