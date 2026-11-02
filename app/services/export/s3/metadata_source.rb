# frozen_string_literal: true

module Export
  module S3
    # Reads service versions from the Metadata API.
    # Everything is exposed lazily so memory use stays flat regardless of
    # how many services or versions exist.
    class MetadataSource
      VersionEntry = Struct.new(:version_id, :metadata, :created_at, keyword_init: true)
      ServiceEntry = Struct.new(:service_id, :settings, :versions, keyword_init: true)

      def initialize(per_page:, query:)
        @per_page = per_page
        @query = query
        @service_api = MetadataApiClient::Service
        @version_api = MetadataApiClient::Version
      end

      # Yields a VersionEntry for every version of every service.
      def each_service_version
        return enum_for(:each_service_version) unless block_given?

        each_service_id do |service_id|
          settings = fetch_settings(service_id)
          versions = []
          each_version_id(service_id) do |version_id|
            version = fetch_version(service_id, version_id)
            metadata = version&.metadata
            created_at = version.created_at
            next unless metadata

            versions << VersionEntry.new(version_id: version_id, metadata: metadata, created_at: created_at)
          end
          yield ServiceEntry.new(service_id: service_id, settings: settings, versions: versions)
        end
      end

      private

      def each_service_id
        each_service do |service|
          service_id = attribute(service, :id)
          yield service_id unless service_id.nil?
        end
      end

      def each_version_id(service_id)
        @version_api.all(service_id).each do |version|
          version_id = version_id_from(version)
          yield version_id unless version_id.nil?
        end
      end

      def fetch_version(service_id, version_id)
        @version_api.find(service_id: service_id, version_id: version_id)
      end

      def fetch_settings(service_id)
        ServiceConfiguration.where(service_id: service_id)
      end

      # Walks the paginated services endpoint.
      def each_service
        page = 1
        seen = 0

        loop do
          response = @service_api.all_services(page: page, per_page: @per_page, query: @query)
          services = response[:services] || []
          break if services.empty?

          services.each { |service| yield service }

          seen += services.size
          break if seen >= response[:total_services].to_i

          page += 1
        end
      end

      def version_id_from(version)
        metadata = attribute(version, :metadata)
        return unless metadata

        metadata['version_id'] || metadata[:version_id]
      end

      # Supports both service objects and hash-based API responses.
      def attribute(object, key)
        if object.respond_to?(key)
          object.public_send(key)
        elsif object.respond_to?(:[])
          object[key] || object[key.to_s]
        end
      end
    end
  end
end
