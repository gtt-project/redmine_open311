module RedmineOpen311
  def self.setup
    ProjectsController.send :helper, RedmineOpen311::ProjectSettingsTabs
  end

  def self.settings
    Setting.plugin_redmine_open311
  end

  def self.project_settings(project)
    (settings['projects'] || {})[project.identifier] || {}
  end

  def self.enabled_projects
    Project.active.
      joins(:enabled_modules).
      references(:enabled_modules).
      where(enabled_modules: { name: 'open311'})
  end

  def self.enabled_trackers
    ids = settings['tracker_ids']
    if ids.blank?
      Tracker.none
    else
      Tracker.where(id: ids)
    end
  end
end
