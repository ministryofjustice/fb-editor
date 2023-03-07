class PublishingPagePresenter
  def initialize(service:, deployment_environment:, service_autocomplete_items:)
    @deployment_environment = deployment_environment
    @service = service
    @service_autocomplete_items = service_autocomplete_items
    @publish_creation = set_publish_creation
  end

  attr_reader :service, :deployment_environment, :service_autocomplete_items
  attr_accessor :publish_creation

  delegate :no_service_output?, to: :publish_creation

  def from_address_warning
    @from_address_warning ||= FromAddressPresenter.new(
      from_address:,
      messages: I18n.t("warnings.from_address.publishing.#{deployment_environment}"),
      service_id: service.service_id
    )
  end

  def submission_warnings
    @submission_warnings ||= SubmissionWarningsPresenter.new(
      submission_warning_presenters,
      deployment_environment
    )
  end

  def autocomplete_warning
    @autocomplete_warning ||= AutocompleteItemsPresenter.new(
      MetadataPresenter::Grid.new(service),
      service_autocomplete_items,
      deployment_environment
    )
  end

  def service_output_warning
    @service_output_warning ||= ServiceOutputWarningPresenter.new(
      service_id: service.service_id,
      deployment_environment:,
      messages: I18n.t('publish.service_output')
    )
  end

  def publish_button_disabled?
    return if deployment_environment == 'dev'

    submission_warnings.messages.any? || autocomplete_warning.messages.any?
  end

  private

  def set_publish_creation
    PublishServiceCreation.new(
      service_id: service.service_id,
      deployment_environment:
    )
  end

  def from_address
    FromAddress.find_or_initialize_by(service_id: service.service_id)
  end

  def submission_pages_presenter
    SubmissionPagesPresenter.new(
      service,
      I18n.t("warnings.submission_pages.#{deployment_environment}")
    )
  end

  def submission_warning_presenters
    presenters = [submission_pages_presenter]

    return presenters if deployment_environment == 'dev'

    presenters.push(from_address_warning) if service_output_warning.blank? && !ENV['REPLY_TO'] == 'enabled'
    presenters.push(autocomplete_warning)
  end
end
