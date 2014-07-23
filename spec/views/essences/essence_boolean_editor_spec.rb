require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_boolean_editor' do
  let(:essence) { Alchemy::EssenceBoolean.new }

  it_behaves_like "an essence editor partial"

  let(:element) { Alchemy::Element.new }
  let(:content) { build_stubbed(:content, essence: essence, name: 'I am content', element: element) }

  it "displays as checkbox" do
    render_essence_editor(content)
    expect(rendered).to have_selector('input[type="checkbox"]')
  end

  context 'if settings[:default_value] is set to true' do
    before { content.stub(settings: {default_value: true}) }

    it "the checkbox is checked" do
      render_essence_editor(content)
      expect(rendered).to have_selector('input[checked="checked"]')
    end
  end

  context 'if options[:default_value] is set to true' do
    it "the checkbox is checked" do
      render_essence_editor(content, default_value: true)
      expect(rendered).to have_selector('input[checked="checked"]')
    end
  end
end
