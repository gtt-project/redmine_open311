require_relative '../test_helper'

class ServiceListTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles, :trackers

  def setup
    super
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
    EnabledModule.create! project: @project, name: 'open311'
    Role.anonymous.add_permission! :access_open311_api
    Setting.plugin_redmine_open311 = {
      'tracker_ids' => [1]
    }
  end

  test 'should require permission' do
    Role.anonymous.remove_permission! :access_open311_api
    get '/georeport/v2/services.xml'
    assert_response 401
  end

  test 'should get service list xml' do
    get '/georeport/v2/services.xml'
    assert_response :success
    xml = xml_data
    assert services = xml.xpath('/services')
    assert_equal 1, services.size
    assert_equal '1', services.xpath('service/service_code').text
    assert_equal 'Bug', services.xpath('service/service_name').text
  end

  test 'should get service list json' do
    get '/georeport/v2/services.json'
    assert_response :success
    assert services = json_data['services']
    assert_equal 1, services.size
    assert_equal 'Bug', services[0]['service_name']
    assert_equal 1, services[0]['service_code']
  end

  test 'should get project service list xml' do
    get '/projects/ecookbook/georeport/v2/services.xml'
    assert_response :success
    xml = xml_data
    assert services = xml.xpath('/services')
    assert_equal 1, services.size
    assert_equal '1', services.xpath('service/service_code').text
    assert_equal 'Bug', services.xpath('service/service_name').text
  end

  test 'should get project service discovery json' do
    get '/projects/ecookbook/georeport/v2/services.json'
    assert_response :success
    assert services = json_data['services']
    assert_equal 1, services.size
    assert_equal 'Bug', services[0]['service_name']
    assert_equal 1, services[0]['service_code']
  end

end


