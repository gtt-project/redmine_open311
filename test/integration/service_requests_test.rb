require_relative '../test_helper'

class ServiceRequestsTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses, :roles, :projects, :members, :member_roles, :trackers, :projects_trackers, :issue_statuses, :enumerations, :workflows

  setup do
    User.current = nil
    @project = Project.find 'ecookbook'
    EnabledModule.delete_all
    EnabledModule.create! project: @project, name: 'open311'
    EnabledModule.create! project: @project, name: 'issue_tracking'
    Role.anonymous.add_permission! :access_open311_api
    Role.anonymous.add_permission! :view_issues
    Role.anonymous.add_permission! :add_issues
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

  test 'index should require api permission' do
    Role.anonymous.remove_permission! :access_open311_api
    get '/projects/ecookbook/georeport/v2/requests.xml'
    assert_response 403
  end

  test 'index should require issues permission' do
    Role.anonymous.remove_permission! :view_issues
    get '/projects/ecookbook/georeport/v2/requests.xml'
    assert_response 403
  end

  test 'create should require add issues permission' do
    Role.anonymous.remove_permission! :add_issues
    post '/projects/ecookbook/georeport/v2/requests.xml'
    assert_response 403
  end

  test 'should get service request' do
    r = create_request.issue
    get "/projects/ecookbook/georeport/v2/requests/#{r.id}.xml"
    assert_response :success
    xml = xml_data
    assert_equal 1, xml.xpath('/service_requests/request').size
    assert_equal r.id.to_s,
      xml.xpath('/service_requests/request/service_request_id').first.text
  end

  test 'should filter project requests' do
    r1 = create_request.issue
    r2 = create_request.issue
    get '/projects/ecookbook/georeport/v2/requests.xml', params: { status: 'closed' }
    assert_response :success
    xml = xml_data
    assert_equal 0, xml.xpath('/service_requests/request').size

    get '/projects/ecookbook/georeport/v2/requests.xml', params: { status: 'open,closed' }
    assert_response :success
    xml = xml_data
    assert_equal 2, xml.xpath('/service_requests/request').size

    get '/projects/ecookbook/georeport/v2/requests.xml', params: { status: 'open' }
    assert_response :success
    xml = xml_data
    assert_equal 2, xml.xpath('/service_requests/request').size

    get '/projects/ecookbook/georeport/v2/requests.xml', params: { service_request_id: r2.id }
    assert_response :success
    xml = xml_data
    assert_equal 1, xml.xpath('/service_requests/request').size
    assert_equal r2.id.to_s,
      xml.xpath('/service_requests/request/service_request_id').first.text
  end

  test 'should get project requests xml' do
    create_request
    get '/projects/ecookbook/georeport/v2/requests.xml'
    assert_response :success
    xml = xml_data
    assert services = xml.xpath('/service_requests')
    assert_equal 1, services.size
    assert_equal '1', services.xpath('request/service_code').text, xml.to_s
    assert_equal 'Bug', services.xpath('request/service_name').text
    assert_equal 'http://example.org/someimage.jpg',
      services.xpath('request/media_url').text
  end

  test 'should get project request json' do
    create_request
    get '/projects/ecookbook/georeport/v2/requests.json'
    assert_response :success
    assert services = json_data['service_requests']
    assert_equal 1, services.size
    assert_equal 'Bug', services[0]['service_name']
    assert_equal 1, services[0]['service_code']
    assert_equal 'http://example.org/someimage.jpg', services[0]['media_url']
  end

  test 'should render error for wrong service_code' do
    post '/projects/ecookbook/georeport/v2/requests.json', params: {
      service_code: 19,
      lat: 123.271, lon: 9.35,
      description: 'some text'
    }
    assert_response :not_found
    assert error = json_data['errors'].first
    assert_equal 404, error['code']
    assert_equal 'Service code invalid', error['description']
  end

  test 'should create request' do
    post '/projects/ecookbook/georeport/v2/requests.json', params: {
      service_code: 1,
      lat: 123.271, lon: 9.35,
      description: 'some text',
      media_url: 'http://example.org/someimage.jpg'
    }
    assert_response :created
    assert issue = @project.issues.find_by_subject('some text')

    assert requests = json_data['service_requests']
    assert req = requests.first
    assert_equal issue.id, req['service_request_id']
    assert_equal 'New', req['service_notice']

    assert_equal 'some text', issue.description
    assert issue.geom.present?
    json = issue.geojson
    assert_equal 'Feature', json['type']
    assert geom = json['geometry']
    assert_equal 'Point', geom['type']
    assert_equal [123.271, 9.35], geom['coordinates']
    assert id = RedmineOpen311.custom_field_id('media_url')
    assert_equal 'http://example.org/someimage.jpg', issue.custom_field_value(id)
  end

  def create_request(args = {})
    r = RedmineOpen311::CreateServiceRequest.({
        service_code: 1,
        lat: 123.271, lon: 9.35,
        description: 'foo',
        media_url: 'http://example.org/someimage.jpg',
      }.merge(args),
      project: @project,
      user: @user
    )
    assert r.request_created, r.error
    r.request
  end

end


