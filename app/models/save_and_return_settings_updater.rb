class SaveAndReturnSettingsUpdater
  attr_reader :save_and_return_settings, :service_id, :service_name

  def initialize(save_and_return_settings:, service_id:, service_name:)
    @save_and_return_settings = save_and_return_settings
    @service_id = service_id
    @service_name = service_name
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_config_save_and_return
    end
  end

  private

  def save_config_save_and_return
    if save_and_return_settings.save_and_return_enabled?
      create_or_update_service_configuration(config: 'SAVE_AND_RETURN', deployment_environment: 'dev')
      create_or_update_service_configuration(config: 'SAVE_AND_RETURN', deployment_environment: 'production')
      create_or_update_service_configuration(config: 'SAVE_AND_RETURN_EMAIL', deployment_environment: 'dev', value: I18n.t('default_values.save_and_return_email', service_name:))
      create_or_update_service_configuration(config: 'SAVE_AND_RETURN_EMAIL', deployment_environment: 'production', value: I18n.t('default_values.save_and_return_email', service_name:))
    end

    unless save_and_return_settings.save_and_return_enabled?
      remove_service_configuration('SAVE_AND_RETURN', 'dev')
      remove_service_configuration('SAVE_AND_RETURN', 'production')
      remove_service_configuration('SAVE_AND_RETURN_EMAIL', 'dev')
      remove_service_configuration('SAVE_AND_RETURN_EMAIL', 'production')
    end
  end

  def create_or_update_service_configuration(config:, deployment_environment:, value: save_and_return)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.value = value
    setting.save!
  end

  def find_or_initialize_setting(config, deployment_environment)
    ServiceConfiguration.find_or_initialize_by(
      service_id:,
      deployment_environment:,
      name: config
    )
  end

  def remove_service_configuration(config, deployment_environment)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.destroy!
  end

  def save_and_return
    @save_and_return ||= save_and_return_settings.save_and_return
  end
end
