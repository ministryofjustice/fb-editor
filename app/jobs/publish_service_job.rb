class PublishServiceJob < ApplicationJob
  queue_as :testable-external-start-page

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
      service_configuration:
    )

    if service_provisioner.valid?
      Publisher.new(
        publish_service:,
        service_provisioner:,
        adapter: Publisher::Adapters::CloudPlatform
      ).call
    else
      raise "Parameters invalid: #{service_provisioner.errors.full_messages}"
    end
  end
end
