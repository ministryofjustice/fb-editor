class ReferencePaymentUpdater
  include ContentSubstitutorHelper

  attr_reader :service, :reference_payment_settings

  CONFIG_WITH_DEFAULTS = %w[
    CONFIRMATION_EMAIL_SUBJECT
    CONFIRMATION_EMAIL_BODY
    SERVICE_EMAIL_SUBJECT
    SERVICE_EMAIL_BODY
    SERVICE_EMAIL_PDF_HEADING
  ].freeze

  def initialize(service:, reference_payment_settings:)
    @service = service
    @reference_payment_settings = reference_payment_settings
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_submission_settings
      save_config_reference_number
      save_config_payment_link
      save_config_with_defaults
    end
  end

  private

  def save_submission_settings
    create_or_update_submission_setting('dev')
    create_or_update_submission_setting('production')
  end

  def create_or_update_submission_setting(deployment_environment)
    submission_setting = SubmissionSetting.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: deployment_environment
    )

    submission_setting.payment_link = reference_payment_settings.payment_link_checked?
    submission_setting.save!
  end

  def save_config_reference_number
    if reference_payment_settings.reference_number_enabled?
      create_or_update_service_configuration(config: 'REFERENCE_NUMBER', deployment_environment: 'dev')
      create_or_update_service_configuration(config: 'REFERENCE_NUMBER', deployment_environment: 'production')
    end

    unless reference_payment_settings.reference_number_enabled?
      remove_service_configuration('REFERENCE_NUMBER', 'dev')
      remove_service_configuration('REFERENCE_NUMBER', 'production')
    end
  end

  def save_config_payment_link
    if reference_payment_settings.payment_link_url_present? &&
        reference_payment_settings.payment_link_checked?
      create_or_update_service_configuration(config: 'PAYMENT_LINK', deployment_environment: 'dev', value: payment_link_url)
      create_or_update_service_configuration(config: 'PAYMENT_LINK', deployment_environment: 'production', value: payment_link_url)
    end
  end

  def create_or_update_service_configuration(config:, deployment_environment:, value: reference_number)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.value = value
    setting.save!
  end

  def find_or_initialize_setting(config, deployment_environment)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: deployment_environment,
      name: config
    )
  end

  def remove_service_configuration(config, deployment_environment)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.destroy!
  end

  def save_config_with_defaults
    %w[dev production].each do |environment|
      CONFIG_WITH_DEFAULTS.each do |config|
        create_or_update_service_configuration(
          config: config,
          deployment_environment: environment,
          value: content_substitutor.public_send(config.downcase)
        )
      end
    end
  end

  def reference_number
    @reference_number ||= reference_payment_settings.reference_number
  end

  def payment_link_url
    @payment_link_url ||= reference_payment_settings.payment_link_url
  end
end
