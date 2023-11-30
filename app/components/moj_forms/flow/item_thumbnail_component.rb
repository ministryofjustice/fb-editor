module MojForms
  module Flow
    class ItemThumbnailComponent < ViewComponent::Base
      delegate :service, to: :helpers
      delegate :payment_link_enabled?, to: :helpers
      attr_reader :title, :thumbnail, :url

      def initialize(title:, thumbnail:, url:)
        super
        @title = title
        @thumbnail = thumbnail
        @url = url
      end

      def thumbnail_path
        "thumbnails/thumbs_#{thumbnail}.jpg"
      end

      def call
        link_to url, class: "flow-thumbnail #{thumbnail} #{payment_link_enabled? ? 'payment-enabled' : ''}", 'aria-hidden': true, tabindex: -1 do
          concat image_pack_tag('thumbnails/thumbs_header.png', class: 'header', alt: '')
          concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
          concat tag.span(title, class: 'title')
          concat image_pack_tag(thumbnail_path, class: 'body', alt: '')
        end
      end
    end
  end
end
