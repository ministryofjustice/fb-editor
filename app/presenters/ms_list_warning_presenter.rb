class MsListWarningPresenter
  attr_accessor :service, :deployment_environment

  def initialize(service:, deployment_environment:)
    @deployment_environment = deployment_environment
    @service = service
  end

  def message
    @publishes = if deployment_environment == 'dev'
                   publishes_dev
                 else
                   publishes_production
                 end

    return if first_publish?
    return if latest.nil?

    if latest.version_id != service.version_id
      link_text
    end
  end

  def link_text
    "#{I18n.t("warnings.publish.#{deployment_environment}.ms_list")}<a href=\"https://moj-forms.service.justice.gov.uk/settings/#ms-lists\">#{I18n.t("warnings.publish.#{deployment_environment}.link_text")}</a>"
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
