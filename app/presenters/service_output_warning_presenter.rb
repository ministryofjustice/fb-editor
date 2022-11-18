class ServiceOutputWarningPresenter
  include ActionView::Helpers
  include GovukLinkHelper

  def initialize(service_id:, deployment_environment:, messages:)
    @deployment_environment = deployment_environment
    @service_id = service_id
    @publish_creation = set_publish_creation
    @messages = messages
  end

  attr_accessor :publish_creation

  delegate :no_service_output?, to: :publish_creation

  delegate :present?, to: :message

  def message
    key = send_confirmation_email? ? :confirmation_email : :default

    if no_service_output?
      messages[key].gsub('%{link}', link).html_safe
    end
  end

  private

  attr_reader :service_id, :messages, :deployment_environment

  def link
    govuk_link_to(
      messages[:link_text],
      Rails.application.routes.url_helpers.settings_email_index_path(service_id)
    )
  end

  def send_confirmation_email?
    @send_confirmation_email ||= SubmissionSetting.find_by(
      service_id: service_id,
      deployment_environment: deployment_environment
    ).try(:send_confirmation_email?)
  end

  def set_publish_creation
    PublishServiceCreation.new(
      service_id: service_id,
      deployment_environment: deployment_environment
    )
  end
end
