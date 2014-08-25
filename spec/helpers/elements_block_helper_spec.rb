require 'spec_helper'

include Alchemy::ElementsHelper
include Alchemy::Admin::ContentsHelper
include Alchemy::Admin::EssencesHelper

module Alchemy
  describe ElementsBlockHelper do
    let(:page)    { build_stubbed(:public_page) }
    let(:element) { build_stubbed(:element, page: page, tag_list: 'foo, bar') }
    let(:content) { build_stubbed(:content, name: 'intro', element: element, ingredient: 'Yahooo') }
    let(:expected_wrapper_tag) { "div.#{element.name}##{element_dom_id(element)}" }

    describe '#element_view_for' do
      context "with block given" do
        it "should yield an instance of ElementViewHelper" do
          expect { |b| element_view_for(element, &b) }.
            to yield_with_args(ElementsBlockHelper::ElementViewHelper)
        end
      end

      context "without block given" do
        subject { element_view_for(element) }

        before do
          element.stub(contents: [content])
        end

        context 'with content view partial present' do
          it "renders element contents view partials by position" do
            expect(subject).to have_selector('h1')
            expect(subject).to have_content('Yahooo')
          end
        end

        context "without content view partial present" do
          let(:content) { build_stubbed(:content, name: 'text', element: element, ingredient: 'Yada') }

          it "renders the essence view instead" do
            expect(subject).to have_content('Yada')
          end
        end
      end

      it "should wrap its output in a DOM element" do
        element_view_for(element).
          should have_css expected_wrapper_tag
      end

      it "should change the wrapping DOM element according to parameters" do
        element_view_for(element, tag: 'span', class: 'some_class', id: 'some_id').
          should have_css 'span.some_class#some_id'
      end

      it "should include the element's tags in the wrapper DOM element" do
        element_view_for(element).
          should have_css "#{expected_wrapper_tag}[data-element-tags='foo bar']"
      end

      it "should use the provided tags formatter to format tags" do
        element_view_for(element, tags_formatter: lambda { |tags| tags.join ", " }).
          should have_css "#{expected_wrapper_tag}[data-element-tags='foo, bar']"
      end

      it "should include the contents rendered by the block passed to it" do
        element_view_for(element) do
          'view'
        end.should have_content 'view'
      end

      context "when/if preview mode is not active" do
        subject { element_view_for(element) }
        it { should have_css expected_wrapper_tag }
        it { should_not have_css "#{expected_wrapper_tag}[data-alchemy-element]" }
      end

      context "when/if preview mode is active" do
        before do
          assign(:preview_mode, true)
          assign(:page, page)
        end

        subject { helper.element_view_for(element) }
        it { should have_css "#{expected_wrapper_tag}[data-alchemy-element='#{element.id}']" }
      end
    end

    describe '#element_editor_for' do
      context 'with block given' do
        it "should yield an instance of ElementEditorHelper" do
          expect { |b| element_editor_for(element, &b) }.
            to yield_with_args(ElementsBlockHelper::ElementEditorHelper)
        end

        it "should not add any extra elements" do
          element_editor_for(element) do
            'view'
          end.should == 'view'
        end
      end

      context "without a block given" do
        subject { element_editor_for(element) }

        before do
          element.stub(contents: [content])
        end

        it "renders element content editors by position" do
          expect(subject).to have_selector('.content_editor')
          expect(subject).to have_selector('[data-content-id]')
        end
      end

      context "with sortable option set to true" do
        subject { element_editor_for(element, sortable: true) }

        it "enables dragndrop sorting" do
          expect(subject).to have_selector('.sortable-contents')
        end
      end

      context "with element having available_contents" do
        subject { element_editor_for(element) }

        before do
          element.stub(available_contents: [content])
        end

        it "renders new content button" do
          expect(subject).to have_selector('.new_content_link')
        end
      end

      context "with element having missing contents" do
        subject { element_editor_for(element) }

        before do
          element.stub(contents: [])
        end

        it "renders missing content buttons" do
          element.content_descriptions.each do |content|
            expect(subject).to have_selector("[data-element-#{element.id}-missing-content=\"#{content['name']}\"]")
          end
        end
      end
    end

    describe ElementsBlockHelper::ElementViewHelper do
      let(:scope) { double }
      subject { ElementsBlockHelper::ElementViewHelper.new(scope, element: element) }

      it 'should have a reference to the specified element' do
        subject.element == element
      end

      describe '#render' do
        it 'should delegate to the render_essence_view_by_name helper' do
          scope.should_receive(:render_essence_view_by_name).with(element, "title", foo: 'bar')
          subject.render :title, foo: 'bar'
        end
      end

      describe '#content' do
        it "should delegate to the element's #content_by_name method" do
          element.should_receive(:content_by_name).with(:title)
          subject.content :title
        end
      end

      describe '#ingredient' do
        it "should delegate to the element's #ingredient method" do
          element.should_receive(:ingredient).with(:title)
          subject.ingredient :title
        end
      end

      describe '#has?' do
        it "should delegate to the element's #has_ingredient? method" do
          element.should_receive(:has_ingredient?).with(:title)
          subject.has? :title
        end
      end

      describe '#essence' do
        it "should provide the specified content essence" do
          subject.should_receive(:content).with(:title).
            and_return(mock_model('Content', :essence => mock_model('EssenceText')))

          subject.essence :title
        end
      end
    end

    describe ElementsBlockHelper::ElementEditorHelper do
      let(:scope) { double }
      subject { ElementsBlockHelper::ElementEditorHelper.new(scope, element: element) }

      it 'should have a reference to the specified element' do
        subject.element == element
      end

      describe '#edit' do
        it "should delegate to the render_essence_editor_by_name helper" do
          scope.should_receive(:render_essence_editor_by_name).with(element, "title", foo: 'bar')
          subject.edit :title, foo: 'bar'
        end
      end
    end
  end
end
