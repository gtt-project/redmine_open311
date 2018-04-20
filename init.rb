require 'redmine'

Rails.configuration.to_prepare do
  RedmineOpen311.setup
end

Redmine::Plugin.register :redmine_open311 do
  name 'Redmine GeoReport Plugin'
  author 'Jens Krämer, Georepublic'
  author_url 'https://hub.georepublic.net/gtt/redmine_open311'
  description 'Adds Open311 API endpoints to Redmine'
  version '1.1.0'

  requires_redmine version_or_higher: '3.4.0'

  settings default: {
    'contact' => '',
    'key_service' => '',
    'landing_page_content' => '',
    'tracker_ids' => []
  }, partial: 'redmine_open311/settings'

  project_module :open311 do
    permission :access_open311_api, {
      open311_v2: %i(discovery services),
      open311_v2_requests: %i( create index show )
    }
  end

end

