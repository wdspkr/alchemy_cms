require 'spec_helper'
include Alchemy::Admin::EssencesHelper
include Alchemy::Admin::ContentsHelper

describe 'alchemy/essences/_essence_richtext_editor' do
  let(:essence) { Alchemy::EssenceRichtext.new }

  it_behaves_like "an essence editor partial"
end
