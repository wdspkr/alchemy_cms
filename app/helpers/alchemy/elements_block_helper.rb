module Alchemy
  # Provides a collection of block-level helpers, allowing for a much more
  # concise way of writing element view/editor partials.
  #
  module ElementsBlockHelper
    # Base class for our block-level helpers.
    #
    class BlockHelper
      def initialize(helpers, opts = {})
        @helpers = helpers
        @opts = opts
      end

      def opts
        @opts
      end

      def element
        opts[:element]
      end

      def helpers
        @helpers
      end
    end

    # Block-level helper class for element views.
    #
    class ElementViewHelper < BlockHelper
      # Renders one of the element's contents.
      #
      def render(name, *args)
        helpers.render_essence_view_by_name(element, name.to_s, *args)
      end

      # Returns one of the element's contents (ie. essence instances).
      #
      def content(name)
        element.content_by_name(name)
      end

      # Returns the ingredient of one of the element's contents.
      #
      def ingredient(name)
        element.ingredient(name)
      end

      # Returns true if the given content has been filled by the user.
      #
      def has?(name)
        element.has_ingredient?(name)
      end

      # Return's the given content's essence.
      #
      def essence(name)
        content(name).try(:essence)
      end
    end

    # Block-level helper class for element editors.
    #
    class ElementEditorHelper < BlockHelper
      def edit(name, *args)
        helpers.render_essence_editor_by_name(element, name.to_s, *args)
      end
    end

    # Block-level helper for element views.
    #
    # Constructs a DOM element wrapping your content element
    # and provides a block helper object you can use for
    # concise access to Alchemy's various helpers.
    #
    # If you omit the block, then all contents view partials get rendered by its position
    #
    # === Block example:
    #
    #   # app/views/alchemy/elements/_element_name_view.html.erb
    #   <%= element_view_for(element) do |el| %>
    #     <%= el.render :title %>
    #     <%= el.render :body %>
    #     <%= link_to "Go!", el.ingredient(:target_url) %>
    #   <% end %>
    #
    # You can override the tag, ID and class used for the generated DOM
    # element:
    #
    #   <%= element_view_for(element, tag: 'span', id: 'my_id', class: 'thing') do |el| %>
    #      <%- ... %>
    #   <% end %>
    #
    # If you don't want your view to be wrapped into an extra element, simply set
    # `tag` to `false`:
    #
    #   <%= element_view_for(element, tag: false) do |el| %>
    #      <%- ... %>
    #   <% end %>
    #
    # === Sorted contents example:
    #
    # Omit the block to render content view partials by its position
    #
    #   # app/views/alchemy/elements/_article_view.html.erb
    #   <%= element_view_for(element) %>
    #
    # ==== Content view partials:
    #
    # If you want to change the markup of the rendered content you can create a content view partial.
    #
    # Content view partials live in a folder inside of `app/views/alchemy/elements`
    # named by its element name:
    #
    #   # app/views/alchemy/elements/article/_headline.html.erb
    #   <h1><%= render_essence_view(content) %></h1>
    #
    # Partial Fallback: If the content editor view is not present,
    # we fall back to render the contents essence view partial instead.
    #
    # @param [Alchemy::Element] element
    #   The element to display.
    # @param [Hash] options
    #   Additional options.
    #
    # @option options :tag (:div)
    #   The HTML tag to be used for the wrapping element.
    # @option options :id (the element's dom_id)
    #   The wrapper tag's DOM ID.
    # @option options :class (the element's essence name)
    #   The wrapper tag's DOM class.
    # @option options :tags_formatter
    #   A lambda used for formatting the element's tags (see Alchemy::ElementsHelper::element_tags_attributes). Set to +false+ to not include tags in the wrapper element.
    #
    def element_view_for(element, options = {})
      options = {
        :tag   => :div,
        :id    => element_dom_id(element),
        :class => element.name,
        :tags_formatter => lambda { |tags| tags.join(" ") }
      }.merge(options)

      # capture inner template block
      output = capture do
        if block_given?
          yield ElementViewHelper.new(self, element: element)
        else
          element.contents.each do |content|
            begin
              # try to render the contents view partial
              concat render(content, content: content)
            rescue ActionView::MissingTemplate
              # if not present we render the contents essence view partial instead
              concat render(content.essence, content: content)
            end
          end
        end
      end

      # wrap output in a useful DOM element
      if tag = options.delete(:tag)
        # add preview attributes
        options.merge!(element_preview_code_attributes(element))

        # add tags
        if tags_formatter = options.delete(:tags_formatter)
          options.merge!(element_tags_attributes(element, formatter: tags_formatter))
        end

        output = content_tag(tag, output, options)
      end

      # that's it!
      output
    end

    # Block-level helper for element editors. Provides a block helper object
    # you can use for concise access to Alchemy's various helpers.
    #
    # If you omit the block, Alchemy renders all content editors by its position.
    #
    # === Block example:
    #
    #   <%= element_editor_for(element) do |el| %>
    #     <%= el.edit :title %>
    #     <%= el.edit :body %>
    #     <%= el.edit :target_url %>
    #   <% end %>
    #
    # === Sortable example:
    #
    #   <%= element_editor_for(element, sortable: true) %>
    #
    # @param [Alchemy::Element] element
    #   The element to display.
    # @param [Hash] options
    #   Additional options.
    #
    # @option options sortable (false)
    #   If you want the contents to be sortable pass true.
    #
    def element_editor_for(element, options = {})
      options = {
        sortable: false
      }.merge(options)

      output = capture do
        if block_given?
          yield ElementEditorHelper.new(self, element: element)
        else
          element.contents.each do |content|
            concat render_essence_editor(content)
          end
          if element.available_contents.any?
            concat render_new_content_link(element)
          end
        end
      end

      if options[:sortable]
        output = content_tag(:div, output, class: 'sortable-contents')
      else
        output
      end
    end

  end
end
