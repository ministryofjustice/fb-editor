class Publisher
  module Utils
    class ServiceMetadataFiles
      attr_reader :service_provisioner, :adapter

      def initialize(service_provisioner, adapter)
        @service_provisioner = service_provisioner
        @adapter = adapter
      end

      def upload
        adapter.upload(
          service_metadata_key,
          service_provisioner.service_metadata
        )

        adapter.upload(
          autocomplete_items_key,
          service_provisioner.autocomplete_items
        )
      end

      private

      def service_metadata_key
        "#{service_provisioner.service_id}_metadata.json"
      end

      def autocomplete_items_key
        "#{service_provisioner.service_id}_autocomplete_items.json"
      end
    end
  end
end
