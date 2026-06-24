module MojForms
  module Flow
    class BranchLinkComponent < ViewComponent::Base
      attr_reader :title, :url

      def initialize(title:, url:)
        super
        @title = title
        @url = url
      end

      def call
        tag.h2 class: 'govuk-body' do
          link_to url, class: 'govuk-link flow-item__title' do
            concat(
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 125" tabindex="-1" focusable="false" role="presentation" aria-hidden="true">
                <polygon fill="" points="1,62.5 100,1 199,62.5 100,124" stroke="" stroke-width="2"/>
                </svg>'.html_safe
            )
            concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
            concat tag.span(title, class: 'text')
          end
        end
      end
    end
  end
end
