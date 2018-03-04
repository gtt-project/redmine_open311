# TODO
# constrain roots to html format

scope 'georeport/v2' do
  root to: 'open311_v2#discovery', as: :open311_root
  get 'discovery', to: 'open311_v2#discovery', as: :open311_discovery
  get 'services', to: 'open311_v2#services', as: :open311_services
end

scope 'projects/:project_id' do
  scope 'georeport/v2' do
    root to: 'open311_v2#discovery', as: :project_open311_root
    get 'discovery', to: 'open311_v2#discovery', as: :project_open311_discovery
    get 'services', to: 'open311_v2#services', as: :project_open311_services
  end
end
