require_relative '../test_helper'

class ServiceDiscoveryTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles

  def setup
    super
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
    EnabledModule.create! project: @project, name: 'open311'
    Role.anonymous.add_permission! :access_open311_api
  end

  test 'should require permission' do
    Role.anonymous.remove_permission! :access_open311_api
    get '/georeport/v2/discovery.xml'
    assert_response 401
  end

  test 'should get service discovery html' do
    get '/georeport/v2'
    assert_response :success
    assert_select '#main ul li', count: 1
    assert_select '#main ul li a', /ecookbook\/georeport\/v2/
  end

  test 'should get service discovery xml' do
    get '/georeport/v2/discovery.xml'
    assert_response :success
    xml = xml_data
    assert endpoints = xml.xpath('/discovery/endpoints')
    assert_equal 1, endpoints.size
    assert_equal 'http://www.example.com/projects/ecookbook/georeport/v2', endpoints.xpath('endpoint/url').text
  end

  test 'should get service discovery json' do
    get '/georeport/v2/discovery.json'
    assert_response :success
    json = json_data['discovery']
    assert endpoints = json['endpoints']
    assert_equal 1, endpoints.size
    assert_equal 'http://www.example.com/projects/ecookbook/georeport/v2', endpoints[0]['url']
  end

  test 'should get project service discovery html' do
    get '/projects/ecookbook/georeport/v2'
    assert_response :success
    assert_select '#main ul li', count: 1
    assert_select '#main ul li a', /ecookbook\/georeport\/v2/
  end

  test 'should get project service discovery xml' do
    get '/projects/ecookbook/georeport/v2/discovery.xml'
    assert_response :success
    xml = xml_data
    assert endpoints = xml.xpath('/discovery/endpoints')
    assert_equal 1, endpoints.size
    assert_equal 'http://www.example.com/projects/ecookbook/georeport/v2', endpoints.xpath('endpoint/url').text
  end

  test 'should get project service discovery json' do
    get '/projects/ecookbook/georeport/v2/discovery.json'
    assert_response :success
    json = json_data['discovery']
    assert endpoints = json['endpoints']
    assert_equal 1, endpoints.size
    assert_equal 'http://www.example.com/projects/ecookbook/georeport/v2', endpoints[0]['url']
  end

end

