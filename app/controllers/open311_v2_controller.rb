class Open311V2Controller < ApplicationController

  before_filter :find_optional_project_and_authorize
  accept_api_auth

  def discovery
    if @project
      @projects = [@project]
      @last_change = @project.updated_on
    else
      @projects = RedmineOpen311::ProjectsQuery.new(params[:contains]).scope
      @last_change = @projects.maximum(:updated_on)
    end
    respond_to do |format|
      format.html{
        @body = RedmineOpen311.settings['landing_page_content']
      }
      format.any{}
    end
  end

  def services
    @trackers = RedmineOpen311.enabled_trackers
  end

  private

  def find_optional_project_and_authorize
    if params[:project_id]
      @project = Project.find params[:project_id]
      authorize
    else
      authorize_global
    end
  end
end
