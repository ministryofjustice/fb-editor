module Admin
  class ApiSubmissionSettingsUpdater
    attr_reader :api_submission_settings, :service

    CONFIG = %w[
      SERVICE_OUTPUT_JSON_ENDPOINT
      SERVICE_OUTPUT_JSON_KEY
    ].freeze

    def initialize(api_submission_settings:, service:)
      @api_submission_settings = api_submission_settings
      @service = service
    end

    def create_or_update!
      ActiveRecord::Base.transaction do
        save_config
      end
    end

    private

    def save_config
      CONFIG.each do |config|
        if params(config).present?
          create_or_update_the_service_configuration(config)
        else
          remove_the_service_configuration(config)
        end
      end
    end

    def params(config)
      api_submission_settings.params(config.downcase.to_sym)
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
        service_id: service.service_id,
        deployment_environment: api_submission_settings.deployment_environment,
        name: config
      )
    end
  end
end
