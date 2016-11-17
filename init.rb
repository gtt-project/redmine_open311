Rails.logger.info 'Starting Open311 plugin for Redmine'

require 'redmine'

OPEN311_VERSION_NUMBER = '0.1.0'

Redmine::Plugin.register :redmine_open311 do
  name 'Redmine Open311 plugin'
  author 'Georepublic'
  description 'This is a plugin for adding Open311 API to Redmine'
  version GTT_VERSION_NUMBER
  url 'https://georepublic.info'
  author_url 'mailto:info@georepublic.de'

	requires_redmine :version_or_higher => '3.3.0'
  requires_redmine_plugin :redmine_gtt, :version_or_higher => "0.1.0"

  project_module :redmine_open311 do
    # Handle project module
  end
end

ActionDispatch::Callbacks.to_prepare do
  # Automatically encode points to geojson with as_json in rails3
  RGeo::ActiveRecord::GeometryMixin.set_json_generator(:geojson)

  # require_dependency 'home_page_redirector'
  require 'redmine_open311'
end
