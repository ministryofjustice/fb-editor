module MojForms
  module Flow
    class FlowItemLink < ViewComponent::Base
      attr_reader :title, :url

      def initialize(title:, url:)
        super
        @title = title
        @url = url
      end

      def call
        tag.h2 class: 'govuk-body' do
          link_to url, class: 'govuk-link flow-item__title' do
            concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
            concat tag.span(title, class: 'text')
          end
        end
      end
    end
  end
end
