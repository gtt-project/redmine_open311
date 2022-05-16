module RedmineOpen311
  class CreateServiceRequest

    Result = ImmutableStruct.new(:request_created?, :error, :request)

    def initialize(params, project:, user: User.current)
      @project = project
      @params = params
      @user = user
    end

    def call
      req = ServiceRequest.new(@params)
      req.project = @project

      if req.valid?
        if create_issue req
          Result.new request: req, request_created: true
        else
          Result.new error: @error, request: req
        end
      else
        Result.new error: req.errors.full_messages, request: req
      end

    end

    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    private

    def create_issue(request)
      issue = @project.issues.build
      issue.tracker = request.tracker
      issue.attributes = {
        priority: RedmineOpen311.new_request_priority,
        author: @user,
        subject: request.subject,
        description: request.description,
      }
      if request.lat && request.lon
        issue.geom = "POINT(#{request.lat} #{request.lon})"
      end

      issue.custom_field_values = Hash[
        RedmineOpen311::CUSTOM_FIELDS.map do |f|
          if id = RedmineOpen311.custom_field_id(f)
            [id, request.send(f)]
          end
        end.compact
      ]

      request.issue = issue
      if issue.save
        true
      else
        @error = issue.errors.full_messages
        false
      end
    end

  end
end
