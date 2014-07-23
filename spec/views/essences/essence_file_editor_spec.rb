require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_file_editor' do
  let(:essence) { Alchemy::EssenceFile.new }

  it_behaves_like "an essence editor partial"

  let(:element) { Alchemy::Element.new }
  let(:content) { build_stubbed(:content, essence: essence, name: 'I am content', element: element) }

  context "with settings[:except]" do
    before { content.stub(settings: {except: 'pdf'}) }

    it "does requests for these type of files" do
      render_essence_editor(content)
      expect(rendered).to have_selector('a[href*="except=pdf"]')
    end
  end

  context "with settings[:only]" do
    before { content.stub(settings: {only: 'pdf'}) }

    it "does requests for these type of files" do
      render_essence_editor(content)
      expect(rendered).to have_selector('a[href*="only=pdf"]')
    end
  end

  context "with options[:except]" do
    it "does requests for these type of files" do
      render_essence_editor(content, except: 'pdf')
      expect(rendered).to have_selector('a[href*="except=pdf"]')
    end
  end

  context "with options[:only]" do
    it "does requests for these type of files" do
      render_essence_editor(content, only: 'pdf')
      expect(rendered).to have_selector('a[href*="only=pdf"]')
    end
  end
end
