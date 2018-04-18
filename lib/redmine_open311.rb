# frozen_string_literal: true

module RedmineOpen311
  def self.setup
    ProjectsController.send :helper, RedmineOpen311::ProjectSettingsTabs
    RedmineOpen311::Patches::ProjectPatch.apply
    RedmineOpen311::Patches::JsonBuilderPatch.apply
  end

  def self.settings
    Setting.plugin_redmine_open311
  end

  def self.project_settings(project)
    (settings['projects'] || {})[project.identifier] || {}
  end

  def self.enabled_projects
    Project.active.visible.
      joins(:enabled_modules).
      references(:enabled_modules).
      where(enabled_modules: { name: 'open311'})
  end

  def self.new_request_priority
    IssuePriority.where(position_name: 'default').first || IssuePriority.first
  end

  def self.enabled_trackers
    ids = settings['tracker_ids']
    if ids.blank?
      Tracker.none
    else
      Tracker.where(id: ids)
    end
  end

  def self.format_datetime(t)
    t.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
  end

  def self.parse_datetime(s)
    DateTime.strptime(s, "%Y-%m-%dT%H:%M:%S%Z").in_time_zone
  end

  CUSTOM_FIELDS = %w(
    address_string
    address_id
    media_url
    account_id
    email
    first_name
    last_name
    phone
    device_id
    zipcode
  )
  CUSTOM_FIELD_KEYS = CUSTOM_FIELDS.map{|f| "#{f}_field".freeze}

  def self.custom_field_id(key)
    settings["#{key}_field"].presence&.to_i
  end

  def self.custom_fields_for_select(key, format: 'string')
    assigned_ids = CUSTOM_FIELD_KEYS.
      map{|k| settings[k]}.reject(&:blank?).compact
    # keep the currently assigned field in the list
    if assigned_id = settings[key].presence
      assigned_ids -= [assigned_id]
    end

    scope = IssueCustomField.sorted.where(field_format: format)
    unless assigned_ids.blank?
      scope = scope.where.not(id: assigned_ids)
    end
    scope.to_a
  end

end
