module MojForms
  module Flow
    class ExternalStartPageThumbnailComponent < ViewComponent::Base
      delegate :service, to: :helpers
      delegate :payment_link_enabled?, to: :helpers
      attr_reader :title, :thumbnail, :url

      def thumbnail_path
        "thumbnails/thumbs_#{thumbnail}.jpg"
      end

      def call
        image_pack_tag('thumbnails/thumbs_external.png', class: 'external-thumbnail', alt: '')
      end
    end
  end
end
