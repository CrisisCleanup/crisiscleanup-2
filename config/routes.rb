Rails.application.routes.draw do
  root 'static_pages#index'

  get "/admin" => 'admin/dashboard#index', as:"dashboard"

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :legacy_events
    resources :legacy_sites
    resources :legacy_organizations
    resources :legacy_contacts
  end


end
