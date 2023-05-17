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
    validate :is_key_valid_length, :is_url_valid

    KEY_LENGTH_ERROR = 'Key length must be 16. '.freeze
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

    def is_key_valid_length
      return if @service_output_json_key == ''

      if @service_output_json_key.nil? || @service_output_json_key.length != 17
        errors.add(:base, KEY_LENGTH_ERROR)
      end
    end

    def is_url_valid
      return if @service_output_json_endpoint == ''

      unless @service_output_json_endpoint =~ URI::DEFAULT_PARSER.make_regexp
        errors.add(:base, URL_ERROR)
      end
    end
  end
end
