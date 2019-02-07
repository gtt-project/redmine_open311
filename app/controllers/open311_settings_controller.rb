class Open311SettingsController < ApplicationController

  before_action :find_project_by_project_id
  before_action :authorize

  def update
    settings = Setting.plugin_redmine_open311
    settings['projects'] ||= {}
    project_settings = settings['projects'][@project.identifier] ||= {}
    project_settings.update params[:settings].permit(:type)

    Setting.plugin_redmine_open311 = settings
    redirect_to settings_project_path(@project, tab: 'open311')
  end

  private

  def authorize
    unless User.current.allowed_to?(:edit_project, @project)
      deny_access and return false
    end
  end
end
