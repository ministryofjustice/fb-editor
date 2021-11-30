class PublishServiceJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    queue_uptime_job(job)
  end

  def perform(publish_service_id:)
    publish_service = PublishService.find(publish_service_id)
    service_configuration = ServiceConfiguration.where(
      service_id: publish_service.service_id,
      deployment_environment: publish_service.deployment_environment
    )

    service_provisioner = Publisher::ServiceProvisioner.new(
      service_id: publish_service.service_id,
      version_id: publish_service.version_id,
      deployment_environment: publish_service.deployment_environment,
      platform_environment: ENV['PLATFORM_ENV'],
      service_configuration: service_configuration
    )

    if service_provisioner.valid?
      Publisher.new(
        publish_service: publish_service,
        service_provisioner: service_provisioner,
        adapter: Publisher::Adapters::CloudPlatform
      ).call
    else
      raise "Parameters invalid: #{service_provisioner.errors.full_messages}"
    end
  end

  def queue_uptime_job(job)
    publish_service = PublishService.find(job.arguments.first)

    if Publisher::UptimeEligibility.new(publish_service).cannot_create?
      Rails.logger.info('Skipping Uptime Check publishing')
      return
    end

    version = MetadataApiClient::Version.find(
      service_id: publish_service.service_id,
      version_id: publish_service.version_id
    )
    service_version = MetadataPresenter::Service.new(version.metadata)

    # First time we need to wait the DNS to be set so we can add
    # Pingdom to the service. Usually 30 minutes.
    UptimeJob.set(wait: 30.minutes).perform_later(
      service_id: service_version.service_id,
      service_name: service_version.service_name,
      host: "#{service_version.service_slug}.#{url_root}",
      action: :create
    )
  end

  def url_root
    Rails.application.config.platform_environments[ENV['PLATFORM_ENV']][:url_root]
  end
end
