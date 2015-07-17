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

    get "/stats" => "stats#index", as: "stats"
    get "/stats/:id" => "stats#by_incident", as: "stats_by_incident"

  end

  get "/dashboard" => 'worker/dashboard#index', as:"dashboard"
  namespace :worker do
     get "/dashboard" => 'dashboard#index', as:"dashboard"
  end

  namespace :incident do
    get "/:id/sites" => "legacy_sites#index", as: "legacy_sites_index"
    get "/:id/organizations" => "legacy_organizations#index", as: "legacy_organizations"
    get "/:id/organizations/:org_id" => "legacy_organizations#show", as: "legacy_organization"
    get "/:id/contacts" => "legacy_contacts#index", as: "legacy_contacts"
    get "/:event_id/contacts/:contact_id" => "legacy_contacts#show", as: "legacy_contact"
  end
end
