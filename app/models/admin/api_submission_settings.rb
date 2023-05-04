module Admin
  class ApiSubmissionSettings < BaseEmailSettings
    attr_accessor :deployment_environment,
                  :service,
                  :name,
                  :service_output_json_endpoint,
                  :service_output_json_key

    validates :deployment_environment, inclusion: {
      in: Rails.application.config.deployment_environments
    }

    def service_output_json_endpoint
      settings_for(:service_output_json_endpoint)
    end

    def service_output_json_key
      settings_for(:service_output_json_key)
    end
  end
end
