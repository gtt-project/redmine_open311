module RedmineOpen311

  # hooks into the helper method that renders the project settings tabs
  module ProjectSettingsTabs

    def project_settings_tabs
      super.tap do |tabs|
        if User.current.allowed_to?(:edit_project, @project) and
          @project.module_enabled?(:open311)

          tabs << {
            name: 'open311',
            action: :open311,
            partial: 'projects/settings/open311',
            label: :label_open311
          }
        end
      end
    end

  end
end

