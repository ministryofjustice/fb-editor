class SettingsUpdater
  attr_reader :settings, :service_id

  def initialize(settings:, service_id:)
    @settings = settings
    @service_id = service_id
  end

  def params(config)
    settings.params(config.downcase.to_sym)
  end

  def create_or_update_the_service_configuration(config)
    setting = find_or_initialize_setting(config)
    setting.value = params(config)
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
end
