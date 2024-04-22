class MsListSettingsUpdater
  attr_reader :ms_list_settings, :service

  def initialize(ms_list_settings:, service:)
    @ms_list_settings = ms_list_settings
    @service = service
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_ms_list_id_setting
    end
  end

  def save_ms_list_id_setting
    submission_setting = SubmissionSetting.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: ms_list_settings.deployment_environment
    )
    submission_setting.send_to_graph_api = ms_list_settings.send_to_ms_list?
    submission_setting.save!

    if ms_list_settings.send_to_ms_list?
      service_config = create_or_update_the_service_configuration('MS_LIST_ID')
      service_config.value = ms_list_settings.ms_list_id
      service_config.save!
    else
      remove_the_service_configuration('MS_LIST_ID')
    end
  end

  def params(config)
    ms_list_settings.params(config.downcase.to_sym)
  end

  def create_or_update_the_service_configuration(config)
    find_or_initialize_setting(config)
  end

  def remove_the_service_configuration(config)
    setting = find_or_initialize_setting(config)
    setting.destroy!
  end

  def find_or_initialize_setting(config)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: ms_list_settings.deployment_environment,
      name: config
    )
  end
end
