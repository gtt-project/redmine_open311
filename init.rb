if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  Rails.application.config.after_initialize do
    RedmineOpen311.setup
  end
else
  Rails.configuration.to_prepare do
    RedmineOpen311.setup
  end
end

Redmine::Plugin.register :redmine_open311 do
  name 'Redmine GeoReport Plugin'
  author 'Jens Krämer, Georepublic'
  author_url 'https://github.com/georepublic'
  url 'https://github.com/gtt-project/redmine_open311'
  description 'Adds Open311 API endpoints to Redmine'
  version '2.0.0'

  requires_redmine version_or_higher: '4.2.0'

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

