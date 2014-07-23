require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_select_editor' do
  let(:essence) { Alchemy::EssenceSelect.new }

  it_behaves_like "an essence editor partial"

  let(:element) { Alchemy::Element.new }
  let(:content) { build_stubbed(:content, essence: essence, name: 'I am content', element: element) }

  context "with no select_values given" do
    it "displays a warning" do
      render_essence_editor(content)
      expect(rendered).to have_selector('.warning')
    end
  end

  context "with select_values given via options" do
    it "shows them as select box" do
      render_essence_editor(content, select_values: [1, 2, 3])
      expect(rendered).to have_selector('option[value="1"]')
      expect(rendered).to have_selector('option[value="2"]')
      expect(rendered).to have_selector('option[value="3"]')
    end
  end

  context "with select_values given via settings" do
    before { content.stub(settings: {select_values: %w(a b c)})}

    it "shows them as select box" do
      render_essence_editor(content)
      expect(rendered).to have_selector('option[value="a"]')
      expect(rendered).to have_selector('option[value="b"]')
      expect(rendered).to have_selector('option[value="c"]')
    end
  end
end
