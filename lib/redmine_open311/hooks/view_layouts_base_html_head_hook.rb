module RedmineOpen311
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener

      include ActionView::Context

      def view_layouts_base_html_head(context={})
        tags = [];
        return tags.join("\n")
      end

      def view_layouts_base_body_bottom(context={})
      end

    end
  end
end
