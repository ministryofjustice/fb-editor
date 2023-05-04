module Admin
  class ApiSubmissionSettings < BaseEmailSettings
    attr_accessor :deployment_environment,
                  :service,
                  # required for settings creation in controller:
                  :service_output_json_endpoint,
                  :service_output_json_key

    validates :deployment_environment, inclusion: {
      in: Rails.application.config.deployment_environments
    }
    validates :service, presence: true
    validate :is_key_valid_lenght
    # , on: :create

    # rubocop:disable Lint/DuplicateMethods. This is required to display in view
    def service_output_json_endpoint
      settings_for(:service_output_json_endpoint)
    end

    def service_output_json_key
      settings_for(:service_output_json_key)
    end
    # rubocop:enable Lint/DuplicateMethods

    # private

    def is_key_valid_lenght
      if :service_output_json_key.to_s.length == 16
        errors.add(:base, 'Key length must be 16')
      end
    end
  end
end
