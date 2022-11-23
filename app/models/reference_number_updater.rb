class ReferenceNumberUpdater
  attr_reader :service_id, :reference_number_settings

  CONFIGS = %w[REFERENCE_NUMBER].freeze

  def initialize(service_id:, reference_number_settings:)
    @service_id = service_id
    @reference_number_settings = reference_number_settings
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_config
    end
  end

  def save_config
    CONFIGS.each do |config|
      if reference_number_settings.enabled? && config.present?
        create_or_update_the_service_configuration(config, 'dev')
        create_or_update_the_service_configuration(config, 'production')
      else
        remove_the_service_configuration(config, 'dev')
        remove_the_service_configuration(config, 'production')
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
end
