module RedmineOpen311
  def self.setup
    ProjectsController.send :helper, RedmineOpen311::ProjectSettingsTabs
  end
end
