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
    validates :service, :service_output_json_key, presence: true
    validate :is_url_valid

    URL_ERROR = 'Endpoint field should be a valid URL. '.freeze

    # rubocop:disable Lint/DuplicateMethods. This is required to display in view
    def service_output_json_endpoint
      settings_for(:service_output_json_endpoint)
    end

    def service_output_json_key
      settings_for(:service_output_json_key)
    end
    # rubocop:enable Lint/DuplicateMethods

    private

    def is_url_valid
      return if @service_output_json_endpoint == ''

      unless @service_output_json_endpoint =~ URI::DEFAULT_PARSER.make_regexp
        errors.add(:base, URL_ERROR)
      end
    end
  end
end
