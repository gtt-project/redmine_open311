require_relative '../test_helper'

class CreateServiceRequestTest < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles, :trackers, :projects_trackers, :issue_statuses, :enumerations, :workflows

  setup do
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
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
    @description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  end

  test 'project should have trackers for open311' do
    assert_equal [1], @project.open311_trackers.map(&:id)
  end

  test 'should create issue' do
    r = RedmineOpen311::CreateServiceRequest.(
      {
        service_code: 1,
        lat: 123.271, lon: 9.35,
        description: @description,
        media_url: 'http://example.org/someimage.jpg',
      },
      project: @project,
      user: @user
    )

    assert r.request_created?, r.error
    assert req = r.request
    assert issue = req.issue
    assert issue.persisted?

    assert_equal 1, issue.tracker_id
    assert_equal Tracker.find(1).default_status, issue.status
    assert_equal @user, issue.author
    assert_equal @description, issue.description
    assert_equal 255, issue.subject.length
    assert issue.geom.present?
    json = issue.geojson
    assert_equal 'Feature', json['type']
    assert geom = json['geometry']
    assert_equal 'Point', geom['type']
    assert_equal [123.271, 9.35], geom['coordinates']
    assert_equal 'http://example.org/someimage.jpg', issue.custom_field_value(@media_url_cf)
  end

end


