require_relative '../test_helper'

class ProjectSettingsTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles

  def setup
    super
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
    EnabledModule.create! project: @project, name: 'open311'
    Role.find(1).add_permission! :edit_project
  end

  test 'project settings should require edit project permission' do
    log_user 'jsmith', 'jsmith'

    get '/projects/ecookbook/settings'
    assert_response :success
    assert_select 'li a', text: 'GeoReport'

    Role.find(1).remove_permission! :edit_project
    get '/projects/ecookbook/settings'
    assert_response :success
    assert_select 'li a', text: 'GeoReport', count: 0
  end


  test 'project settings should require enabled module' do
    log_user 'jsmith', 'jsmith'
    Role.find(1).add_permission! :edit_projects

    get '/projects/ecookbook/settings'
    assert_response :success
    assert_select 'li a', text: 'GeoReport'

    EnabledModule.delete_all
    get '/projects/ecookbook/settings'
    assert_response :success
    assert_select 'li a', text: 'GeoReport', count: 0
  end

end


