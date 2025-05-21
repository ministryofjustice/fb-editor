class UnpublishDevServices
  include MetadataVersionHelper

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
                    .reject { |ps| ps.service_id.in?(ACCEPTANCE_TEST_FORMS) }
                    .select(&:completed?)
  end

  def published_dev_services
    published_services.select { |ps| ps.deployment_environment == 'dev' }
  end

  def service_slug_config(service_id)
    ServiceConfiguration.find_by(
      service_id:,
      name: 'SERVICE_SLUG',
      deployment_environment: 'dev'
    )&.decrypt_value
  end

  def service_slug(service_id, version_metadata)
    service_slug_config(service_id).presence || service_slug_from_name(version_metadata)
  end
end
