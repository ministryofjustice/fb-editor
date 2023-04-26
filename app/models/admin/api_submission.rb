module Admin
  class ApiSubmission
    SERVICE_OUTPUT_JSON_ENDPOINT = 'SERVICE_OUTPUT_JSON_ENDPOINT'.freeze
    SERVICE_OUTPUT_JSON_KEY = 'SERVICE_OUTPUT_JSON_KEY'.freeze
    include ActiveModel::Model

    validates :service_id, presence: true

    def service_id(service_id)
      @service_id = service_id
    end

    def initialize
      # TODO: set in dev here like reference number
      if endpoint_key.blank?
        @endpoint_url = 'Not filled in'
        @endpoint_key = 'Not filled in yet either'
      else
        endpoint_key
        endpoint_url
      end
      @deployment_environment = 'dev'
    end

    def endpoint_url
      @endpoint_url = service_config(name: SERVICE_OUTPUT_JSON_ENDPOINT).decrypt_value if service_config(name: SERVICE_OUTPUT_JSON_ENDPOINT).present?
    end

    def endpoint_key
      @endpoint_key = service_config(name: SERVICE_OUTPUT_JSON_KEY).decrypt_value if service_config(name: SERVICE_OUTPUT_JSON_KEY).present?
    end

    def create_servx§ice_configurations(url, key)
      @endpoint_url = url
      @endpoint_key = key
      create_or_update_configuration(name: SERVICE_OUTPUT_JSON_ENDPOINT, value: url)
      create_or_update_configuration(name: SERVICE_OUTPUT_JSON_KEY, value: key)
    end

    def delete_service_configurations
      delete_service_configuration(name: SERVICE_OUTPUT_JSON_ENDPOINT)
      delete_service_configuration(name: SERVICE_OUTPUT_JSON_KEY)
    end

    private

    def service_config(name:)
      @service_config ||= ServiceConfiguration.find_by(service_id: @service_id, deployment_environment: @deployment_environment, name:)
    end

    def create_or_update_configuration(name:, value:)
      service_configuration = ServiceConfiguration.find_or_initialize_by(
        service_id: @service_id,
        deployment_environment: @deployment_environment,
        name:
      )
      service_configuration.value = value
      service_configuration.save!
    end

    def delete_service_configuration(name:)
      ServiceConfiguration.destroy_by(
        service_id:,
        deployment_environment: @deployment_environment,
        name:
      )
    end
  end
end
