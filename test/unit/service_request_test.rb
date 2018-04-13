require_relative '../test_helper'

class ServiceRequestTest < ActiveSupport::TestCase

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

  test 'should initialize from params' do
    r = ServiceRequest.new(
      service_code: 1,
      lat: 123.271, lon: 9.35,
      description: @description,
      media_url: 'http://example.org/foo.jpg',
    )

    assert_equal 1, r.service_code
    assert_equal @description, r.description
    assert_equal 255, r.subject.length
    assert_equal 123.271, r.lat
    assert_equal 9.35, r.lon
    assert_equal 'http://example.org/foo.jpg', r.media_url

    r.project = @project
    assert_equal 1, r.tracker.id
  end

end



