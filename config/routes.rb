Rails.application.routes.draw do
  devise_for :users, path:'',:path_names => {:sign_in => 'login', :sign_out => 'logout'}
  root 'static_pages#index'

  get "/admin" => 'admin/dashboard#index'

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :legacy_events
    resources :legacy_sites
    resources :legacy_organizations
    resources :legacy_contacts
  end

  get "/dashboard" => 'volunteer/dashboard#index', as:"dashboard"
  namespace :volunteer do
     get "/dashboard" => 'dashboard#index', as:"dashboard"
  end



end
