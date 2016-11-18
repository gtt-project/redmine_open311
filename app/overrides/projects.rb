Deface::Override.new(
  :virtual_path => "projects/show",
  :name => "deface_view_projects_show_format_open311",
  :insert_after => "erb[loud]:contains('PDF')",
  :partial => "projects/show/open311"
)
