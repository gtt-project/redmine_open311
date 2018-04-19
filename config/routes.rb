# TODO
# constrain roots to html format

get 'georeport', to: 'open311_v2#discovery'

scope 'georeport/v2' do
  root to: 'open311_v2#discovery', as: :open311_root
  get 'discovery', to: 'open311_v2#discovery', as: :open311_discovery
  get 'services', to: 'open311_v2#services', as: :open311_services
end

scope 'projects/:project_id' do

  resource :open311_settings, only: :update

  scope 'georeport/v2' do
    root to: 'open311_v2#discovery', as: :project_open311_root
    get 'discovery', to: 'open311_v2#discovery', as: :project_open311_discovery
    get 'services', to: 'open311_v2#services', as: :project_open311_services

    resources :requests, only: %i(index create show), controller: :open311_v2_requests
  end
end
