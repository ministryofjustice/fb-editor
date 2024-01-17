module MojForms
  class BackLinkComponent < GovukComponent::Base
    attr_reader :text, :href

    def initialize(href:, text: '', classes: [], html_attributes: {})
      @href = href
      @text = text

      super(classes:, html_attributes:)
    end

    def before_render
      @text = @text.presence || t('actions.back')
    end

    def call
      link_to href, **html_attributes do
        concat tag.span '<svg width="7" height="12" viewBox="0 0 7 12" fill="none" role="image" aria-hidden="true">
        <path fill-rule="evenodd" clip-rule="evenodd" d="M5.75345 0L6.46045 0.706L1.41445 5.753L6.46045 10.799L5.75345 11.507L0.000449181 5.753L5.75345 0Z" fill="currentColor"/>
        </svg>'.html_safe
        concat tag.span link_content
      end
    end

    private

    def link_content
      content || text || raise(ArgumentError, 'no text or content')
    end

    def default_attributes
      { class: %w[mojf-back-link] }
    end
  end
end
