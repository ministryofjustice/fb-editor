class PublishingPagePresenter
  def initialize(service, deployment_environment, service_autocomplete_items)
    @deployment_environment = deployment_environment
    @service = service
    @publish_creation = PublishServiceCreation.new(
      service_id: service.service_id,
      deployment_environment: deployment_environment
    )
  end

  attr_reader :service, :deployment_environment
  attr_accessor :publish_creation

  delegate :no_service_output?, to: :publish_creation

  def from_address_presenter
    @from_address_presenter ||= FromAddressPresenter.new(
      from_address,
      I18n.t("warnings.from_address.publishing.#{deployment_environment}"),
      service.service_id
    )
  end

  def submission_warnings
    @submission_warnings ||= SubmissionWarningsPresenter.new(
      [submission_pages_presenter, from_address_presenter],
      deployment_environment
    )
  end

  def autocomplete_warning
    @autocomplete_warning ||= AutocompleteItemsPresenter.new(service, service_autocomplete_items)
  end

  def submission_warnings
    @submission_warnings ||= SubmissionPresenter.new(
      [submission_pages, from_address_presenter],
      deployment_environment
    )
  end

  def publish_button_disabled?(autocomplete_warning)
    return false if no_service_output?
    return false unless deployment_environment == 'production'

    submission_warnings.messages.any? || autocomplete_warning.messages.any?
  end

  private

  def from_address
    FromAddress.find_or_initialize_by(service_id: service.service_id)
  end

  def submission_pages_presenter
    SubmissionPagesPresenter.new(
      service,
      I18n.t("warnings.submission_pages.#{deployment_environment}")
    )
  end
end
