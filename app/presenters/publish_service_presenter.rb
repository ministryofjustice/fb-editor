class PublishServicePresenter
  include ::Publisher::Utils::Hostname
  attr_reader :service, :publish_service

  delegate :deployment_environment, to: :publish_service
  delegate :service_slug, to: :service

  def initialize(publish_service_query, service)
    @publishes = publish_service_query
    @publish_service = latest
    @service = service
  end

  def latest
    @publishes&.last
  end

  def published?
    latest.present?
  end

  def first_publish?
    @publishes.count == 1
  end

  def url
    "https://#{hostname}" if published?
  end
end
