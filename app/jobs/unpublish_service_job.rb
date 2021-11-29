class UnpublishServiceJob < ApplicationJob
  queue_as :default

  def perform(publish_service_id:, service_slug:)
    publish_service = PublishService.find(publish_service_id)
    Unpublisher.new(
      publish_service: publish_service,
      platform_environment: ENV['PLATFORM_ENV'],
      service_slug: service_slug,
      adapter: adapter
    ).call
  end

  def success(job)
    publish_service = PublishService.find(job.arguments.first[:publish_service_id])

    if UptimeEligibility.new(publish_service).cannot_destroy?
      Rails.logger.info('Skipping Pingdom unpublishing.')
      return
    end

    version = MetadataApiClient::Version.find(
      service_id: publish_service.service_id,
      version_id: publish_service.version_id
    )
    service_version = MetadataPresenter::Service.new(version.metadata)

    UptimeJob.perform_later(
      service_id: service_version.service_id,
      action: :destroy
    )
  end

  def adapter
    if Rails.env.development?
      Unpublisher::Adapters::Local
    else
      Unpublisher::Adapters::CloudPlatform
    end
  end
end
