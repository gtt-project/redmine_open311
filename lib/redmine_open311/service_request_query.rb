module RedmineOpen311
  class ServiceRequestQuery

    class InvalidQueryParams < StandardError; end

    MAX_DAYS = 90.days
    MAX_REQUESTS = 1000


    def initialize(project, params = {})
      @project = project

      unless @request_ids = params[:service_request_id]&.split(',')

        @service_codes = params[:service_code]&.split(',')

        @status_list = params[:status]&.split(',') || %w(open closed)


        if d = params[:start_date].presence
          @start_date = RedmineOpen311.parse_datetime d
        end

        if d = params[:end_date].presence
          @end_date = RedmineOpen311.parse_datetime d
        end

        if @start_date
          @end_date ||= @start_date + MAX_DAYS
        elsif @end_date
          @start_date = @end_date - MAX_DAYS
        else
          @start_date = MAX_DAYS.ago
        end

        if @end_date and (@end_date - @start_date) > MAX_DAYS
          raise ArgumentError, 'date range too long'
        end
      end
    end


    def scope
      return Issue.none if tracker_ids.blank?

      scope = @project.issues.visible.
        limit(MAX_REQUESTS).eager_load(:status).
        where(tracker_id: tracker_ids)

      if @request_ids
        if @request_ids.any?
          scope = scope.where(id: @request_ids)
        else
          scope = Issue.none
        end
      else
        if @start_date
          scope = scope.where "#{Issue.table_name}.created_on >= ?", @start_date
        end

        if @end_date
          scope = scope.where "#{Issue.table_name}.created_on <= ?", @end_date
        end

        if @status_list.size == 1 # no filtering necessary for 'any' status
          is_closed = @status_list[0] == 'closed'
          scope = scope.where("#{IssueStatus.table_name}.is_closed = ?", is_closed)
        end

      end

      scope
    end


    def tracker_ids
      @tracker_ids ||= begin
        trackers = @project.open311_trackers
        trackers = trackers.where(id: @service_codes) if @service_codes
        trackers.pluck(:id)
      end
    end
  end
end
