class Unpublisher
  module Adapters
    class Local
      include ActiveModel::Model
      attr_accessor :publish_service, :platform_environment, :service_slug

      def unpublishing
        publish_service.update!(status: 'unpublishing')
      end

      def unpublished
        publish_service.update!(status: 'unpublished')
      end
    end
  end
end
