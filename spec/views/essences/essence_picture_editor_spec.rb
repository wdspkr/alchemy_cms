require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_picture_editor' do
  let(:essence) { Alchemy::EssencePicture.create }

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

  context "if displayed as gallery editor" do
    before { render_essence_editor(content, grouped: true) }

    it "does not show the label" do
      expect(rendered).to_not have_selector('label')
    end

    it "wrapper has grouped class" do
      expect(rendered).to have_selector('.content_editor.grouped')
    end
  end
end
