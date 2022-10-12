class UnpublishTestServices
  include MetadataVersionHelper

  ACCEPTANCE_TEST_SERVICES = [
    'cd75ad76-1d4b-4ce5-8a9e-035262cd2683', # New Runner Service
    'e68dca75-20b8-468e-9436-e97791a914c5'  # Branching Fixture 10 Service
  ].freeze
  ENVIRONMENTS = %i[dev production].freeze
  SELECT_LATEST_PUBLISH_SERVICE_RECORD = 'SELECT DISTINCT ON (service_id) * FROM publish_services ORDER BY service_id, created_at DESC'.freeze

  def call
    ENVIRONMENTS.each do |environment|
      send(environment).each do |publish_service|
        version_metadata = get_version_metadata(publish_service)
        UnpublishServiceJob.perform_later(
          publish_service_id: publish_service.id,
          service_slug: service_slug(version_metadata)
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
end
