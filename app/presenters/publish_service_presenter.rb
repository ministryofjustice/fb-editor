class PublishServicePresenter
  include ::Publisher::Utils::Hostname
  attr_reader :service, :publish_service

  delegate :deployment_environment, to: :publish_service

  def initialize(publish_service_query, service)
    @publishes = publish_service_query
    @publish_service = latest
    @service = service
  end

  def service_slug
    service_slug_config || service.service_slug
  end

  def latest
    @publishes&.last
  end

  def published?
    latest&.published?
  end

  def first_publish?
    last_unpublish = @publishes.unpublished.last
    if last_unpublish
      @publishes.published.since(last_unpublish.created_at).count == 1
    else
      @publishes.published.count == 1
    end
  end

  def url
    "https://#{hostname}" if published?
  end

  private

  def service_slug_config
    @service_slug_config ||= ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'SERVICE_SLUG'
    )&.decrypt_value
  end
end
