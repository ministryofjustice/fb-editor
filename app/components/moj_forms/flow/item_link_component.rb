module MojForms
  module Flow
    class ItemLinkComponent < ViewComponent::Base
      attr_reader :title, :type, :url

      def initialize(title:, type:, url:)
        super
        @title = title
        @type = type
        @url = url
      end

      def call
        tag.h2 class: 'govuk-body' do
          link_to url, class: 'govuk-link flow-item__title' do
            concat tag.span(title, class: 'text')
            concat tag.span(",  + #{t("pages.flow.page_types.#{type}")}", class: 'govuk-visually-hidden')
          end
        end
      end
    end
  end
end
