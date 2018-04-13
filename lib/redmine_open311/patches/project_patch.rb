module RedmineOpen311
  module Patches
    module ProjectPatch

      def self.apply
        Project.prepend self unless Project < self
      end

      def open311_trackers
        trackers.where(id: RedmineOpen311.enabled_trackers.pluck(:id))
      end
    end
  end
end
