require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_date_editor' do
  let(:essence) { Alchemy::EssenceDate.new }

  it_behaves_like "an essence editor partial"

  let(:element) { Alchemy::Element.new }
  let(:content) { build_stubbed(:content, essence: essence, name: 'I am content', element: element) }

  it "displays as date input" do
    render_essence_editor(content)
    expect(rendered).to have_selector('input[type="date"]')
  end

  context 'if settings[:default_value] is set' do
    before { content.stub(settings: {default_value: '2014-12-06'}) }

    it "the default value is displayed" do
      render_essence_editor(content)
      expect(rendered).to have_selector('input[value="2014-12-06"]')
    end
  end

  context 'if options[:default_value] is set' do
    it "the default value is displayed" do
      render_essence_editor(content, default_value: '2014-12-06')
      expect(rendered).to have_selector('input[value="2014-12-06"]')
    end
  end
end
