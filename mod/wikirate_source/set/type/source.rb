require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :source_type, type: :pointer, default: "[[Link]]"

add_attributes :import
attr_accessor :import

def source_title_card
  # FIXME: needs codename, but :title is linked to *title
  Card.fetch name.field("title"), new: {}
end

def import?
  # default (=nil) means true
  #
  @import != false && Cardio.config.x.import_sources
end

require "link_thumbnailer"

def not_bot?
  Card::Auth.current_id == Card::WagnBotID
end

event :check_source, :validate, on: :create do
  source_cards = assemble_source_subfields
  validate_source_subfields source_cards
end

event :add_source_name_to_params, :finalize, on: :create do
  special_research_page_stuff
end

def special_research_page_stuff save=false
  if success.params[:view] == "source_tab"
    success.source ||= Array(Env.params[:source]) || []
    success.source << name
    if (company = Env.params.dig :card,:subcards,"+company", :content)
      success.company = company
      new_sources = add_subcard [company, :new_sources], type_id: SessionID
      new_sources.add_item name
      new_sources.save if save # if not in event phase we have to save
    end
  end
end

def assemble_source_subfields
  [:wikirate_link, :file, :text].map do |fieldname|
    subfield fieldname
  end.compact
end

def validate_source_subfields source_cards
  if source_cards.length > 1
    errors.add :source, "Only one type of content is allowed"
  elsif source_cards.empty?
    errors.add :source, "Source content required"
  end
end

def source_type_codename
  source_type_card.item_cards[0].codename.to_sym
end

def analysis_names
  return [] unless topic_list && company_list
  company_list.item_names.map do |company|
    topic_list.item_names.map do |topic|
      "#{company}+#{topic}"
    end
  end.flatten
end

def analysis_cards
  analysis_names.map { |aname| Card.fetch aname }
end

def topic_list
  @topic_list ||= fetch trait: :wikirate_topic
end

def company_list
  @company_list ||= fetch trait: :wikirate_company
end

def wikirate_link?
  source_type_codename == :wikirate_link
end

event :import_linked_source, :integrate_with_delay, on: :save, when: :wikirate_link? do
  # in theory, this should be in source_type/wikirate_link.rb, but that was causing
  # problems as detailed here: https://www.pivotaltracker.com/story/show/152409610
  generate_pdf if import? && html_link?
end

format :html do
  view :new do
    preview? ? _render_new_preview : super()
  end

  view :open_content do
    _render_preview
  end

  def preview?
    return false if @previewed
    @previewed = true
    Env.params[:preview]
  end

  view :new_preview, cache: :never, tags: :unknown_ok do
    with_nest_mode :edit do
      voo.structure = "metric value source form"
      voo.type = "source"
      card_form :create, "main-success" => "REDIRECT",
                         "data-form-for" => "new_metric_value",
                         class: "card-slot new-view TYPE-source" do
        output [
          preview_hidden,
          new_view_hidden,
          new_view_type,
          _render_content_formgroup,
          _render_preview_buttons
        ]
      end
    end
  end

  def new_view_hidden
    hidden_tags success: {
      id: "_self", soft_redirect: true, view: :source_and_preview
    }
  end

  view :preview_buttons do
    button_formgroup do
      wrap_with :button, "Add and preview", class: "btn btn-primary pull-right",
                                            data: { disable_with: "Adding" }
    end
  end

  def preview_hidden
    hidden_field_tag "card[subcards][+company][content]", Env.params[:company]
  end
end

format :json do
  def essentials
    {
      type: card.source_type_card.item_names.first,
      title: card.source_title_card.content
    }
  end
end
