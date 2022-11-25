class ReferenceNumberUpdater
  attr_reader :service_id, :reference_number_settings, :service_name

  CONFIGS = %w[REFERENCE_NUMBER].freeze

  CONFIG_WITH_DEFAULTS = %w[
    CONFIRMATION_EMAIL_SUBJECT
    CONFIRMATION_EMAIL_BODY
    SERVICE_EMAIL_SUBJECT
    SERVICE_EMAIL_BODY
    SERVICE_EMAIL_PDF_HEADING
  ].freeze

  def initialize(service_id:, reference_number_settings:, service_name:)
    @service_id = service_id
    @reference_number_settings = reference_number_settings
    @service_name = service_name
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_config
    end
  end

  def save_config
    CONFIGS.each do |config|
      if reference_number_settings.enabled?
        create_or_update_the_service_configuration(config, 'dev')
        create_or_update_the_service_configuration(config, 'production')
        save_config_with_reference_number_defaults
      else
        remove_the_service_configuration(config, 'dev')
        remove_the_service_configuration(config, 'production')
        save_config_with_defaults
      end
    end
  end

  def create_or_update_the_service_configuration(config, deployment_environment)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.value = reference_number_settings.reference_number
    setting.save!
  end

  def find_or_initialize_setting(config, deployment_environment)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service_id,
      deployment_environment: deployment_environment,
      name: config
    )
  end

  def remove_the_service_configuration(config, deployment_environment)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.destroy!
  end

  def create_or_update_the_service_configuration_adding_default_value(config, deployment_environment, value)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.value = value
    setting.save!
  end

  def save_config_with_defaults
    CONFIG_WITH_DEFAULTS.each do |config|
      create_or_update_the_service_configuration_adding_default_value(
        config,
        'dev',
        I18n.t("default_values.#{config.downcase}", service_name: service_name)
      )
      create_or_update_the_service_configuration_adding_default_value(
        config,
        'production',
        I18n.t("default_values.#{config.downcase}", service_name: service_name)
      )
    end
  end

  def save_config_with_reference_number_defaults
    CONFIG_WITH_DEFAULTS.each do |config|
      create_or_update_the_service_configuration_adding_default_value(
        config,
        'dev',
        I18n.t("default_values.reference_number.#{config.downcase}", service_name: service_name)
      )
      create_or_update_the_service_configuration_adding_default_value(
        config,
        'production',
        I18n.t("default_values.reference_number.#{config.downcase}", service_name: service_name)
      )
    end
  end
end
