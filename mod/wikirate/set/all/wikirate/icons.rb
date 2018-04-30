ICON_MAP = {
  wikirate_company: :business,
  wikirate_topic: :widgets,
  project: [:flask, { library: :font_awesome }],
  subproject: [:flask, { library: :font_awesome }],
  metric: ["bar-chart", { library: :font_awesome }],
  researcher: [:user, { library: :font_awesome }],
  post: :insert_comment,
  details: :info,
  source: :public,
  score: :adjust,
  year: :calendar,
  research_group: [:users, { library: :font_awesome }],
  contributions: [:plug, { library: :font_awesome }],
  activity: :directions_run
}.freeze

format :html do
  def icon_map key
    ICON_MAP[key]
  end
end