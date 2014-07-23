require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_html_editor' do
  let(:essence) { Alchemy::EssenceHtml.new }

  it_behaves_like "an essence editor partial"
end
