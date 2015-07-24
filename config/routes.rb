Rails.application.routes.draw do
  devise_for :users, path:'',:path_names => {:sign_in => 'login', :sign_out => 'logout'}
  root 'static_pages#index'
  
  get "/about" => "static_pages#about", as: "about"
  get "/privacy" => "static_pages#privacy", as: "privacy"
  get "/terms" => "static_pages#terms", as: "terms"    
    
  get "/admin" => 'admin/dashboard#index'

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :legacy_events do
      resources :forms
    end
    resources :legacy_sites, except: [:show]
    resources :legacy_organizations, except: [:show]
    resources :legacy_contacts, except: [:show]
    resources :users, except: [:show]

    get "/stats" => "stats#index", as: "stats"
    get "/stats/:id" => "stats#by_incident", as: "stats_by_incident"
    post '/legacy_organizations/verify' => "legacy_organizations#verify"
    get "/import" => "import#form", as: "csv_import_form"
  end

  
  get "/dashboard" => 'worker/dashboard#index', as:"dashboard"
  namespace :worker do
     get "/dashboard" => 'dashboard#index', as:"dashboard"
     resource :invitation_lists, only: [:create]
    
  end

  namespace :incident do
    get "/:id/sites" => "legacy_sites#index", as: "legacy_sites_index"
    get "/:id/organizations" => "legacy_organizations#index", as: "legacy_organizations"
    get "/:id/organizations/:org_id" => "legacy_organizations#show", as: "legacy_organization"
    get "/:id/contacts" => "legacy_contacts#index", as: "legacy_contacts"
    get "/:event_id/contacts/:contact_id" => "legacy_contacts#show", as: "legacy_contact"
    get "/:id/map" => "legacy_sites#map", as: "legacy_map"
    get "/:id/form" => "legacy_sites#form", as: "legacy_form"
    post "/:id/submit" => "legacy_sites#submit"
  end
  
  get "/invitations/activate" => "invitations#activate"
  post "/invitations/activate" => "invitations#sign_up"
  post "/verify/:user_id" => "worker/dashboard#verify_user"


  namespace :api do
    # TODO /import
    get "/map" => "json#map", as: "json_map"
    get "/spreadsheets/sites" => "spreadsheets#sites", as: "sites_spreadsheet"
    get "/public/map" => "public/json#map", as: "public_json_map"
    post "/import" => "import#csv", as: "import_csv"
  end

  # Organization Registrations
  get "/register" => 'registrations#new'
  post "/register" => 'registrations#create'

end
