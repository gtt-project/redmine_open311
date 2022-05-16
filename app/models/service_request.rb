# frozen_string_literal: true

class ServiceRequest
  include ActiveModel::Validations

  ATTRIBUTES = %i(
    jurisdiction_id
    service_code
    lat lon
    description
    attribute
  ) + RedmineOpen311::CUSTOM_FIELDS.map(&:to_sym) - [:zipcode] # zipcode should be determined internally from address I think, not part of the POST definition

  attr_accessor :project, :issue
  attr_reader(*ATTRIBUTES)

  # checks validity of jurisdiction_id and service_code
  class JurisdictionValidator < ActiveModel::Validator
    def validate(record)
      if record.jurisdiction_project.nil?
        record.errors.add :jurisdiction_id, :invalid
      elsif record.tracker.nil?
        record.errors.add :service_code, :invalid
      end
    end
  end

  validates :project, presence: true
  validates :service_code, presence: true
  validates_with JurisdictionValidator

  validates :lat, :lon, presence: true, numericality: { only_float: true },
    if: ->(){ address_id.blank? and address_string.blank? }

  validates :address_string, presence: true,
    if: ->(){ (lat.blank? or lon.blank?) and address_id.blank? }

  validates :address_id, presence: true,
    if: ->(){ (lat.blank? or lon.blank?) and address_string.blank? }

  validates :description, length: { maximum: 4000 }, allow_nil: true


  def initialize(params)
    ATTRIBUTES.each do |attribute|
      instance_variable_set "@#{attribute}", params[attribute].presence
    end
  end

  def jurisdiction_project
    @jurisdiction_project ||= if jurisdiction_id.present?
      Project.where(project.project_condition(true)).
              where(identifier: project.jurisdiction_id).first
    else
      project
    end
  end

  def tracker
    @tracker ||= jurisdiction_project.open311_trackers.find_by_id(service_code)
  end

  class TextHelper
    include ActionView::Helpers::TextHelper
  end

  def subject
    @subject ||= TextHelper.new.truncate(description, length: 255)
  end

  # used for rendering the creation / list response


end
