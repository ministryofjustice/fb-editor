# frozen_string_literal: true

module Export
  module S3
    # Reads services with associated metadata and items from MetadataApiClient::Service api.
    class MetadataSource
      VersionEntry = Struct.new(:version_id, :service_id, :metadata, :created_at, :locale, keyword_init: true)
      ServiceEntry = Struct.new(:service_id, :settings, :versions, keyword_init: true)

      def initialize(per_page:)
        @per_page = per_page
        @service_api = MetadataApiClient::Service
      end

      # Yields a VersionEntry for every version of every service.
      def each_service_version
        fetch_all_services.map do |service|
          settings = fetch_service_settings(service.id)
          versions = []
          service.metadata['metadata'].each do |metadata|
            versions << VersionEntry.new(version_id: metadata['id'], service_id: metadata['service_id'], metadata: metadata['data'], created_at: metadata['created_at'], locale: metadata['locale'])
          end
          ServiceEntry.new(service_id: service.id, settings: settings, versions: versions)
        end
      end

      private

      def fetch_service_settings(service_id)
        ServiceConfiguration.where(service_id: service_id)
      end

      def fetch_all_services
        page = 1
        services = []
        loop do
          response = MetadataApiClient::Service.all_services(page: page, per_page: @per_page, include: 'metadata')
          break if response[:services].empty?

          response[:services].each do |service|
            services << service
          end
          page += 1
        end
        services
      end
    end
  end
end
