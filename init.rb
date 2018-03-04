require 'redmine'

Rails.configuration.to_prepare do
  RedmineOpen311.setup
end

Redmine::Plugin.register :redmine_open311 do
  name 'Redmine Open311 Plugin'
  author 'Jens Krämer, Georepublic'
  author_url 'https://hub.georepublic.net/gtt/redmine_open311'
  description 'Adds open311 API endpoints to Redmine'
  version '0.1.0'

  requires_redmine version_or_higher: '3.4.0'

  settings default: {
  }, partial: 'redmine_open311/settings'

  project_module :open311 do
    permission :access_open311_api, {}
  end

end

