module RedmineOpen311
  class ServiceRequestDecorator

    attr_reader :issue

    delegate :id, :description, to: :issue

    def initialize(issue)
      @issue = issue
    end

    def account_id
      custom_field_value('account_id') || @issue.author_id
    end

    def service_notice
      @issue.status.name
    end

    def status
      @issue.status.is_closed? ? 'closed' : 'open'
    end

    # maybe last comment? / last comment where status was changed
    def status_notes
    end

    def service_name
      @issue.tracker.name
    end

    def service_code
      @issue.tracker_id
    end

    def agency_responsible
      @issue.assigned_to&.name
    end

    def requested_datetime
      format_datetime @issue.created_on
    end

    def updated_datetime
      format_datetime @issue.updated_on
    end

    def expected_datetime
      if date = @issue.due_date
        format_datetime Time.use_zone('UTC'){date.end_of_day}
      end
    end

    def address
      custom_field_value 'address'
    end

    def address_id
      custom_field_value 'address_id'
    end

    def zipcode
      custom_field_value 'zipcode'
    end

    def lat
      coordinates&.first
    end

    def long
      coordinates&.last
    end

    def media_url
      custom_field_value 'media_url'
    end

    private

    def format_datetime(t)
      RedmineOpen311.format_datetime t
    end

    def coordinates
      @issue.geom&.coordinates
    end

    def custom_field_value(key)
      if id = RedmineOpen311.custom_field_id(key)
        @issue.custom_field_value(id).presence
      end
    end


  end
end
