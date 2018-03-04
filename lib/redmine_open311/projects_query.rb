module RedmineOpen311
  class ProjectsQuery
    def initialize(contains = nil)
      @contains = contains.presence
    end

    def scope
      projects = RedmineOpen311.enabled_projects
      if @contains
        projects = projects.where(
          Project.send(:sanitize_sql_array, [
            "#{Project.table_name}.geom is not null and " +
            "ST_Intersects(#{Project.table_name}.geom," +
            "              ST_GeomFromText('%s', 4326))",
            @contains
          ])
        )
      end
      projects
    end

  end

end
