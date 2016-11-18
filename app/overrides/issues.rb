Deface::Override.new(
  :virtual_path => "issues/index",
  :name => "deface_view_issues_index_format_open311",
  :insert_after => "erb[loud]:contains('PDF')",
  :partial => "issues/index/open311"
)

Deface::Override.new(
  :virtual_path => "issues/show",
  :name => "deface_view_issues_show_format_open311",
  :insert_after => "erb[loud]:contains('PDF')",
  :partial => "issues/show/open311"
)
