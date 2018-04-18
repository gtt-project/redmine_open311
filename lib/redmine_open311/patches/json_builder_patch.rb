module RedmineOpen311
  module Patches
    module JsonBuilderPatch
      def self.apply
        if Redmine::Views::Builders::Json.instance_methods.include?(:request) and
          !(Redmine::Views::Builders::Json < self)

          Redmine::Views::Builders::Json.prepend self
        end
      end

      def self.prepended(*_)
        Redmine::Views::Builders::Json.remove_possible_method(:request)
        Redmine::Views::Builders::Json.remove_possible_method(:response)
      end

      def output
        json = @struct.first.to_json
        if jsonp.present?
          json = "#{jsonp}(#{json})"
          @response.content_type = 'application/javascript'
        end
        json
      end

    end
  end
end
