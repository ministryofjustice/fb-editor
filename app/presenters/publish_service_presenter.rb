class PublishServicePresenter
  include ::Publisher::Utils::Hostname
  attr_reader :service, :publish_service

  delegate :deployment_environment, to: :publish_service
  delegate :service_slug, to: :service

  def initialize(publish_service, service)
    @publish_service = publish_service
    @service = service
  end

  def url
    "https://#{hostname}"
  end
end
