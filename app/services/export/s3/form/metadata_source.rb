# frozen_string_literal: true

module Export
  module S3::Form
    # Reads services with their metadata, items and settings from the Metadata API
    # and exposes them as a stream of ServiceEntry objects.
    #
    # Services are fetched page by page and yielded lazily, so memory use stays
    # flat regardless of how many services exist.
    #
    #   source = Export::S3::Form::MetadataSource.new(per_page: 20)
    #   source.each_service_version { |entry| ... } # entry is a ServiceEntry
    #   source.each_service_version.first(5)        # also works without a block
    class MetadataSource
      class Error < StandardError; end

      VersionEntry = Struct.new(:version_id, :service_id, :metadata, :created_at, :locale, :deployment_environments, keyword_init: true)
      ServiceEntry = Struct.new(:service_id, :service_name, :settings, :items, :versions, :service_created_by, :service_created_at, :service_updated_at, keyword_init: true)

      def initialize(per_page:, deployment_environments: [])
        @per_page = per_page
        @service_api = MetadataApiClient::Service
        @settings_model = ServiceConfiguration
        @deployment_environments = deployment_environments
      end

      # Yields one ServiceEntry per service, each holding all of its versions.
      # Returns an Enumerator when called without a block.
      def each_service_version
        return enum_for(:each_service_version) unless block_given?

        each_page_of_services do |services|
          settings_by_service = load_settings(services.map(&:id))

          services.each do |service|
            yield build_service_entry(service, settings_by_service.fetch(service.id, []))
          end
        end
      end

      private

      def fetch_service_settings(service_id)
        ServiceConfiguration.where(service_id: service_id)
      end

      def each_page_of_services
        page = 1
        loop do
          services = fetch_page(page)
          return if services.empty?

          yield services
          page += 1
        end
      end

      # One query per page of services instead of one per service.
      def load_settings(service_ids)
        @settings_model.where(service_id: service_ids).to_a.group_by(&:service_id)
      end

      def build_service_entry(service, settings)
        payload = service.metadata || {}

        ServiceEntry.new(
          service_id: service.id,
          service_name: service.name,
          service_created_by: payload['service_created_by'],
          service_created_at: payload['service_created_at'],
          service_updated_at: payload['service_updated_at'],
          settings: settings,
          items: payload['items'] || [],
          versions: Array(payload['metadata']).map { |version| build_version_entry(version) }
        )
      end

      def build_version_entry(version)
        VersionEntry.new(
          version_id: version['id'],
          service_id: version['service_id'],
          metadata: version['data'],
          created_at: version['created_at'],
          locale: version['locale'],
          deployment_environments: @deployment_environments.join('_')
        )
      end

      def fetch_page(page)
        response = @service_api.published_services(page: page, per_page: @per_page, deployment_environments: @deployment_environments)
        Array(response && response[:services])
      end
    end
  end
end
