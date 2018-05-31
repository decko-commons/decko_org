# -*- encoding : utf-8 -*-

describe Card::Set::Type::PlainText do
  it "has special editor" do
    assert_view_select render_editor("Plain Text"), 'textarea[rows="5"]'
  end

  it "has special content that escapes HTML" do
    expect(render_card(:core, type: "Plain Text", content: "<b></b>"))
      .to eq "&lt;b&gt;&lt;/b&gt;"
  end
end
