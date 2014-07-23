require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_link_editor' do
  let(:essence) { Alchemy::EssenceLink.new }

  it_behaves_like "an essence editor partial"

  let(:element) { Alchemy::Element.new }
  let(:content) { build_stubbed(:content, essence: essence, name: 'I am content', element: element) }

  it "has hidden fields for all link attributes" do
    render_essence_editor(content)
    expect(rendered).to have_selector("input[type=\"hidden\"][name=\"#{content.form_field_name(:link)}\"]")
    expect(rendered).to have_selector("input[type=\"hidden\"][name=\"#{content.form_field_name(:link_title)}\"]")
    expect(rendered).to have_selector("input[type=\"hidden\"][name=\"#{content.form_field_name(:link_class_name)}\"]")
    expect(rendered).to have_selector("input[type=\"hidden\"][name=\"#{content.form_field_name(:link_target)}\"]")
  end
end
