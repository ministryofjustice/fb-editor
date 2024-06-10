class MsListWarningPresenter
  attr_accessor :service, :deployment_environment

  def initialize(service:, deployment_environment:)
    @deployment_environment = deployment_environment
    @service = service
  end

  def message
    # byebug
    @publishes = if deployment_environment == 'dev'
                   publishes_dev
                 else
                   publishes_production
                 end
    # byebug
    return if first_publish?
    return if latest.nil?

    if latest.version_id != service.version_id
      I18n.t("warnings.publish.#{deployment_environment}.ms_list")
    end
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

  def publishes_dev
    @publishes_dev ||= PublishService.where(
      service_id: service.service_id
    ).dev
  end

  def publishes_production
    @publishes_production ||= PublishService.where(
      service_id: service.service_id
    ).production
  end
end
