module RedmineOpen311
  class ProjectsQuery
    def initialize(contains = nil)
      @contains = contains.presence
    end

    def scope
      RedmineGtt::SpatialProjectsQuery.new(
        contains: @contains, projects: RedmineOpen311.enabled_projects
      ).scope
    end

  end

end
