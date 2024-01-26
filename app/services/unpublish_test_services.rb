class UnpublishTestServices
  include MetadataVersionHelper
  ACCEPTANCE_TEST_SERVICES = [
    'cd75ad76-1d4b-4ce5-8a9e-035262cd2683', # New Runner Service
    'e68dca75-20b8-468e-9436-e97791a914c5', # Branching Fixture 10 Service
    '759716eb-b4fb-413e-b883-f7016e2a9feb', # Save and Return v2 Service
    '11744bdf-86e3-4be3-b2cc-86434dc08ef2', # Conditional content Service
    '1ef15479-5a2c-4426-a5bf-54253031d9be', # API Submission JSON Output v2 Service
    '3d1cf5f3-47f3-4aeb-ae63-c2d15ce5378a'  # External start page form
  ].freeze
  ENVIRONMENTS = %i[dev production].freeze
  SELECT_LATEST_PUBLISH_SERVICE_RECORD = 'SELECT DISTINCT ON (service_id) * FROM publish_services ORDER BY service_id, created_at DESC'.freeze

  def call
    ENVIRONMENTS.each do |environment|
      send(environment).each do |publish_service|
        version_metadata = get_version_metadata(publish_service)
        UnpublishServiceJob.perform_later(
          publish_service_id: publish_service.id,
          service_slug: service_slug(publish_service.service_id, version_metadata)
        )
      end
    end
  end

  private

  def published_services
    @published_services ||=
      PublishService.find_by_sql(SELECT_LATEST_PUBLISH_SERVICE_RECORD)
                    .reject { |ps| ps.service_id.in?(ACCEPTANCE_TEST_SERVICES) }
                    .select(&:completed?)
  end

  def dev
    published_services.select { |ps| ps.deployment_environment == 'dev' }
  end

  def production
    published_services.select { |ps| ps.deployment_environment == 'production' }
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
