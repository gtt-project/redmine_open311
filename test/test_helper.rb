require_relative '../../../test/test_helper'

Redmine::IntegrationTest.class_eval do

  def xml_data
    Nokogiri::XML(@response.body)
  end

  def json_data
    JSON.parse(@response.body)
  end

end

