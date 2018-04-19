require_relative '../test_helper'

class ServiceRequestQueryTest < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles, :trackers, :projects_trackers, :issue_statuses, :enumerations, :workflows

  setup do
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
    EnabledModule.create! project: @project, name: 'issue_tracking'
    EnabledModule.create! project: @project, name: 'open311'
    @media_url_cf = IssueCustomField.create!(
      name: 'Media URL',
      field_format: 'string',
      tracker_ids: [1],
      is_for_all: '1'
    )
    Setting.plugin_redmine_open311 = {
      'tracker_ids' => [1],
      'media_url_field' => @media_url_cf.id.to_s
    }
    @user = User.find_by_login 'jsmith'
  end

  test 'should find requests' do
    assert r = create_request
    assert i = r.issue

    q = RedmineOpen311::ServiceRequestQuery.new( @project, {} )
    scope = q.scope
    assert_equal 1, scope.size
    assert_equal i, scope.first
  end

  test 'should find requests by service code' do
    assert r = create_request
    assert i = r.issue

    q = RedmineOpen311::ServiceRequestQuery.new( @project, {service_code: '2,3'} )
    scope = q.scope
    assert_equal 0, scope.size

    q = RedmineOpen311::ServiceRequestQuery.new( @project, {service_code: '2,1'} )
    scope = q.scope
    assert_equal 1, scope.size
    assert_equal i, scope.first
  end

  test 'should filter by id' do
    r1 = create_request.issue
    r1.update_column :status_id, 5
    r2 = create_request.issue

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { service_request_id: "#{r1.id},9999", status: 'open'}
    ).scope
    assert_equal 1, scope.size # default filter: any status
    assert_equal r1, scope.first # id overrids all other filters

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { service_request_id: "#{r1.id},9999,#{r2.id}" }
    ).scope
    assert_equal 2, scope.size # default filter: any status
  end

  test 'should filter by status' do
    r1 = create_request.issue
    r1.update_column :status_id, 5
    r2 = create_request.issue

    scope = RedmineOpen311::ServiceRequestQuery.new(@project).scope
    assert_equal 2, scope.size # default filter: any status

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { status: 'open' }
    ).scope
    assert_equal 1, scope.size
    assert_equal r2, scope.first

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { status: 'closed' }
    ).scope
    assert_equal 1, scope.size
    assert_equal r1, scope.first

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { status: 'open,closed'}
    ).scope
    assert_equal 2, scope.size
  end

  test 'should filter by date' do
    r1 = create_request.issue
    r1.update_column :created_on, 100.days.ago
    r2 = create_request.issue
    r2.update_column :created_on, 20.days.ago

    scope = RedmineOpen311::ServiceRequestQuery.new(@project).scope
    assert_equal 1, scope.size # default filter: last 90 days
    assert_equal r2, scope.first


    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { start_date: format_time(120.days.ago) }
    ).scope
    assert_equal 1, scope.size # -120 + 90 days
    assert_equal r1, scope.first

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { end_date: format_time(30.days.ago) }
    ).scope
    assert_equal 1, scope.size # -120 + 90 days
    assert_equal r1, scope.first

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { start_date: format_time(110.days.ago),
                  end_date: format_time(105.days.ago)}
    ).scope
    assert_equal 0, scope.size

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { start_date: format_time(80.days.ago),
                  end_date: format_time(60.days.ago)}
    ).scope
    assert_equal 0, scope.size

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { start_date: format_time(10.days.ago),
                  end_date: format_time(30.days.ago)}
    ).scope
    assert_equal 0, scope.size

    scope = RedmineOpen311::ServiceRequestQuery.new(
      @project, { start_date: format_time(30.days.ago),
                  end_date: format_time(10.days.ago)}
    ).scope
    assert_equal 1, scope.size
    assert_equal r2, scope.first
  end

  test 'should have tracker ids' do
    q = RedmineOpen311::ServiceRequestQuery.new(@project, {})
    assert_equal [1], q.tracker_ids

    q = RedmineOpen311::ServiceRequestQuery.new(@project,
                                                {service_code: '2,1'})
    assert_equal [1], q.tracker_ids

    q = RedmineOpen311::ServiceRequestQuery.new(@project,
                                                {service_code: '2,3'})
    assert_equal [], q.tracker_ids

  end


  def format_time(t)
    RedmineOpen311.format_datetime t
  end

  def create_request(params = {})
    r = RedmineOpen311::CreateServiceRequest.({
        service_code: 1,
        lat: 123.271, lon: 9.35,
        description: 'foo',
        media_url: 'http://example.org/someimage.jpg',
      }.merge(params),
      project: @project,
      user: @user
    )
    assert r.request_created?
    r.request
  end
end




