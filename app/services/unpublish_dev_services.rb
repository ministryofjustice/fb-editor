class UnpublishDevServices
  include MetadataVersionHelper
  AUTOMATED_TEST_SERVICES = [
    'cd75ad76-1d4b-4ce5-8a9e-035262cd2683', # New Runner Service
    'e68dca75-20b8-468e-9436-e97791a914c5', # Branching Fixture 10 Service
    '57497ef9-61cb-4579-ab93-f686e09d6936'  # Smoke Tests V2
  ].freeze
  SELECT_LATEST_PUBLISH_SERVICE_RECORD = 'SELECT DISTINCT ON (service_id) * FROM publish_services ORDER BY service_id, created_at DESC'.freeze

  def call
    published_dev_services.each do |publish_service|
      version_metadata = get_version_metadata(publish_service)
      UnpublishServiceJob.perform_later(
        publish_service_id: publish_service.id,
        service_slug: service_slug(publish_service.service_id, version_metadata)
      )
    end
  end

  private

  def published_services
    @published_services ||=
      PublishService.find_by_sql(SELECT_LATEST_PUBLISH_SERVICE_RECORD)
                    .reject { |ps| ps.service_id.in?(AUTOMATED_TEST_SERVICES) }
                    .select(&:completed?)
  end

  def published_dev_services
    published_services.select { |ps| ps.deployment_environment == 'dev' }
  end

  def service_slug_config(service_id)
    ServiceConfiguration.find_by(
      service_id:,
      name: 'SERVICE_SLUG'
    )&.decrypt_value
  end

  def service_slug(service_id, version_metadata)
    service_slug_config(service_id).presence || service_slug_from_name(version_metadata)
  end
end
