class Open311V2RequestsController < ApplicationController

  accept_api_auth

  before_filter :find_project_by_project_id
  before_filter :authorize

  def index
    @requests = RedmineOpen311::ServiceRequestQuery.new(
      @project
    ).scope
  end


  def show
    @request = @project.issues.visible.find params[:id]
  end


  def create
    r = RedmineOpen311::CreateServiceRequest.(params, project: @project)

    if r.request_created?
      @request = r.request
      render 'create', status: :created
    else
      if req = r.request and req.invalid?
        if req.service_code.blank?
          open311_error(message: "no service code given")
        elsif req.errors[:service_code].any? || req.errors[:jurisdiction_id].any?
          open311_error(status: 404, message: req.errors.full_messages.join(". "))
        else
          open311_error(message: req.errors.full_messages.join(". "))
        end
      else
        open311_error(status: 500, messge: r.error)
      end
    end
  end

  private

  def authorize(ctrl = params[:controller], action = params[:action], global = false)
    perm = 'create' == action ? :add_issues : :view_issues
    if User.current.allowed_to?(perm, @project)
      super
    else
      deny_access
    end
  end


  def open311_error(status: 400, message: 'your request could not be processed')
    logger.info("open311_error: #{status} / #{message}")
    @code = status
    @description = message
    render 'open311_v2/error', status: status
  end
end

