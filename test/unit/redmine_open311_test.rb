require_relative '../test_helper'

class RedmineOpen311Test < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles, :trackers, :projects_trackers, :issue_statuses, :enumerations, :workflows

  setup do
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
    EnabledModule.create! project: @project, name: 'open311'
    Setting.plugin_redmine_open311 = {
    }
    @user = User.find_by_login 'jsmith'
    @description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  end

  test 'project should have trackers for open311' do
    with_settings(plugin_redmine_open311: { 'tracker_ids' => [1] }) do
      assert_equal [1], RedmineOpen311.enabled_trackers.map(&:id)
    end
  end

  test 'should format and parse timestamps' do
    now = Time.now
    assert str = RedmineOpen311.format_datetime(now)
    assert ts = RedmineOpen311.parse_datetime(str)
    assert_equal str, RedmineOpen311.format_datetime(ts)
    assert_equal now.to_i, ts.to_i
  end

  test 'should have default issue priority' do
    assert_equal 5, RedmineOpen311.new_request_priority.id
  end

  test 'should find custom field id' do
    media_url_cf = IssueCustomField.create!(
      name: 'Media URL',
      field_format: 'string',
      tracker_ids: [1],
      is_for_all: '1'
    )
    with_settings(plugin_redmine_open311: { 'media_url_field' => media_url_cf.id.to_s }) do
      assert id = RedmineOpen311.custom_field_id('media_url')
      assert_equal media_url_cf.id, id
    end
  end
end



