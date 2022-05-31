class FormAnalyticsUpdater
  attr_reader :settings, :service_id

  def initialize(settings:, service_id:)
    @settings = settings
    @service_id = service_id
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_form_analytics_config
    end
  end

  def save_form_analytics_config
    settings.environments.each do |environment|
      settings.config_names.each do |config|
        deployment_environment = FormAnalyticsSettings::PLATFORM_DEPLOYMENTS[environment]
        setting_name = "#{config}_#{environment}".downcase
        value = settings.instance_param(setting_name)

        if settings.enabled?(environment) && value.present?
          create_or_update_the_service_configuration(config, value, deployment_environment)
        else
          remove_the_service_configuration(config, deployment_environment)
        end
      end
    end
  end

  def create_or_update_the_service_configuration(config, value, deployment_environment)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.value = value
    setting.save!
  end

  def remove_the_service_configuration(config, deployment_environment)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.destroy!
  end

  def find_or_initialize_setting(config, deployment_environment)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service_id,
      deployment_environment: deployment_environment,
      name: config
    )
  end
end
