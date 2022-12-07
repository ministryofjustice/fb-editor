class ReferencePaymentUpdater
  include ContentSubstitutorHelper

  attr_reader :service, :reference_payment_settings

  CONFIGS = %w[REFERENCE_NUMBER PAYMENT_LINK].freeze
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
      save_config
      save_config_with_defaults
    end
  end

  private

  def save_config
    CONFIGS.each do |config|
      if reference_payment_settings.reference_number_enabled? && config == 'REFERENCE_NUMBER'
        create_or_update_service_configuration(config: config, deployment_environment: 'dev')
        create_or_update_service_configuration(config: config, deployment_environment: 'production')
      end

      if !reference_payment_settings.reference_number_enabled? && config == 'REFERENCE_NUMBER'
        remove_service_configuration(config, 'dev')
        remove_service_configuration(config, 'production')
      end

      if reference_payment_settings.payment_link_url_present? &&
          reference_payment_settings.payment_link_checked? &&
          config == 'PAYMENT_LINK'
        create_or_update_service_configuration(config: config, deployment_environment: 'dev', value: payment_link_url)
        create_or_update_service_configuration(config: config, deployment_environment: 'production', value: payment_link_url)
      end

      next unless (!reference_payment_settings.payment_link_url_present? ||
          !reference_payment_settings.payment_link_checked?) &&
        config == 'PAYMENT_LINK'

      remove_service_configuration(config, 'dev')
      remove_service_configuration(config, 'production')
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
