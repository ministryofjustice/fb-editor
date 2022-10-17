class MaintenanceModeSettingsUpdater
  attr_reader :settings, :service_id

  BINARY_CONFIGS = %w[MAINTENANCE_MODE].freeze

  CONFIGS = %w[
    MAINTENANCE_PAGE_HEADING
    MAINTENANCE_PAGE_CONTENT
  ].freeze

  def initialize(settings:, service_id:)
    @settings = settings
    @service_id = service_id
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_config
      save_binary_configs
    end
  end

  def save_config
    CONFIGS.each do |config|
      if params(config).present?
        create_or_update_the_service_configuration(config)
      end
    end
  end

  def save_binary_configs
    BINARY_CONFIGS.each do |config|
      config_value = params(config)
      if config_value.present? && config_value == '1'
        create_or_update_the_service_configuration(config)
      else
        remove_the_service_configuration(config)
      end
    end
  end

  def create_or_update_the_service_configuration(config)
    value = params(config)
    if config == 'MAINTENANCE_PAGE_CONTENT'
      value = Base64.encode64(value)
    end
    setting = find_or_initialize_setting(config)
    setting.value = value
    setting.save!
  end

  def remove_the_service_configuration(config)
    setting = find_or_initialize_setting(config)
    setting.destroy!
  end

  def find_or_initialize_setting(config)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service_id,
      deployment_environment: settings.deployment_environment,
      name: config
    )
  end

  def params(config)
    settings.params(config.downcase.to_sym)
  end
end
