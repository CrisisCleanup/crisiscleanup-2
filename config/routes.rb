Rails.application.routes.draw do
  devise_for :users, path:'',:path_names => {:sign_in => 'login', :sign_out => 'logout'}
  root 'static_pages#index'

  get "/about" => "static_pages#about", as: "about"
  get "/government" => "static_pages#government", as: "government"
  get "/voad" => "static_pages#voad", as: "voad"
  get "/survivor" => "static_pages#survivor", as: "survivor"
  get "/volunteer" => "static_pages#volunteer", as: "volunteer"
  get "/training" => "static_pages#training", as: "training"
  get "/public_map" => "static_pages#public_map", as: "public_map"
  get "/privacy" => "static_pages#privacy", as: "privacy"
  get "/terms" => "static_pages#terms", as: "terms"
  get "/admin" => 'admin/dashboard#index'
  get "/signup" => 'static_pages#signup', as: "signup"
  get "/new_incident" => 'static_pages#new_incident', as: "new_incident"
  post "/request_incident" => 'static_pages#request_incident', as: "request_incident"
  get "/redeploy" => 'static_pages#redeploy', as: "redeploy"
  get "/donate" => 'static_pages#donate', as: "donate"
  get "/contact" => 'static_pages#contact', as: "contact"

  resources :request_invitations, only: [:new, :create]
  
  resources :users
  
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
  get "/redeploy_form" => 'worker/dashboard#redeploy_form', as: "redeploy_form"
  post "/redeploy_request" => 'worker/dashboard#redeploy_request', as: "redeploy_request"

  namespace :worker do
    get "/incident-chooser" => "dashboard#incident_chooser", as: "incident_chooser"
    get "/dashboard" => 'dashboard#index', as:"dashboard"
    resource :invitation_lists, only: [:create]
    resources :temporary_passwords, only: [:create, :new]
    post "temporary_passwords/authorize" => "temporary_passwords#authorize", as: "authorize_temporary_password"

    namespace :incident do
      # This should be an events (incident) controller
      get "/:id/download-sites" => "legacy_sites#csv", as: "sites_download"

      get "/:id/sites" => "legacy_sites#index", as: "legacy_sites_index"
      get "/:id/organizations" => "legacy_organizations#index", as: "legacy_organizations"
      get "/:id/organizations/:org_id" => "legacy_organizations#show", as: "legacy_organization"
      get "/:id/contacts" => "legacy_contacts#index", as: "legacy_contacts"
      get "/:id/contacts/:contact_id" => "legacy_contacts#show", as: "legacy_contact"
      get "/:id/map" => "legacy_sites#map", as: "legacy_map"
      get "/:id/form" => "legacy_sites#form", as: "legacy_form"
      get "/:id/edit/:site_id" => "legacy_sites#map", as: "legacy_edit_site"
      post "/:id/edit/:site_id" => "legacy_sites#update", as:"legacy_update_site"
      post "/:id/submit" => "legacy_sites#submit"
      get "/:id/stats" => "legacy_sites#stats", as: "stats"
      get "/:id/print/:site_id" => "legacy_sites#print", as: "print"
    end

  end

  get "/invitations/activate" => "invitations#activate"
  post "/invitations/activate" => "invitations#sign_up"

  namespace :api do
    # TODO /import
    get "/map/:event_id/:limit/:page" => "json#map", as: "json_map"
    get "/site/:id" => "json#site", as: "json_site"
    post "/update-site-status/:id" => "json#update_legacy_site_status", as: "json_site_status"
    post "/claim-site/:id" => "json#claim_legacy_site"
    get "/spreadsheets/sites" => "spreadsheets#sites", as: "sites_spreadsheet"
    get "/public/map/:event_id/:limit/:page" => "public/json#map", as: "public_json_map"
    get "/count/:event_id" => "public/json#siteCount"
    get "/public/contacts" => "public/json#contacts", as: "public_json_contacts"
    post "/import" => "import#csv", as: "import_csv"
    get "/pdf/site" => "pdf#site", as: "pdf_site"
  end

  # Organization Registrations
  get "/register" => 'registrations#new', as: "register_path"
  post "/register" => 'registrations#create'
  get "/welcome" => 'registrations#welcome'

  # Errors
  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#server_error"
end
