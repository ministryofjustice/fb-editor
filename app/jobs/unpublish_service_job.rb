class UnpublishServiceJob < ApplicationJob
  queue_as :default

  def perform(publish_service_id:, service_slug:)
    publish_service = PublishService.find(publish_service_id)
    Unpublisher.new(
      publish_service:,
      platform_environment: ENV['PLATFORM_ENV'],
      service_slug:,
      adapter:
    ).call
  end

  def adapter
    if Rails.env.development?
      Unpublisher::Adapters::Local
    else
      Unpublisher::Adapters::CloudPlatform
    end
  end
end
