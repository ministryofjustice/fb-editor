module Admin
  class ApiSubmission
    SERVICE_OUTPUT_JSON_ENDPOINT = 'SERVICE_OUTPUT_JSON_ENDPOINT'.freeze
    SERVICE_OUTPUT_JSON_KEY = 'SERVICE_OUTPUT_JSON_KEY'.freeze
    include ActiveModel::Model
    attr_accessor :name, :value

    validates :service_id, :deployment_environment, presence: true

    def service_id(service_id)
      @service_id = service_id
    end

    def deployment_environment(deployment_environment)
      @deployment_environment = deployment_environment
    end

    # def initialize
    #   if endpoint_key.blank?
    #     @endpoint_url = 'Not filled in'
    #     @endpoint_key = 'Not filled in yet either'
    #   else
    #     endpoint_key
    #     endpoint_url
    #   end
    # end

    def endpoint_url
      @endpoint_url = service_config(name: SERVICE_OUTPUT_JSON_ENDPOINT).decrypt_value if service_config(name: SERVICE_OUTPUT_JSON_ENDPOINT).present?
    end

    def endpoint_key
      @endpoint_key = service_config(name: SERVICE_OUTPUT_JSON_KEY).decrypt_value if service_config(name: SERVICE_OUTPUT_JSON_KEY).present?
    end

    def create_service_configurations(url, key)
      @endpoint_url = url
      @endpoint_key = key
      create_or_update_configuration(name: SERVICE_OUTPUT_JSON_ENDPOINT, value: url)
      create_or_update_configuration(name: SERVICE_OUTPUT_JSON_KEY, value: key)
    end

    def delete_service_configurations
      delete_service_configuration(name: SERVICE_OUTPUT_JSON_ENDPOINT)
      delete_service_configuration(name: SERVICE_OUTPUT_JSON_KEY)
    end

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

    def find_urls(deployment_environment:)
      ServiceConfiguration.find_by(service_id: @service_id, deployment_environment:, name: SERVICE_OUTPUT_JSON_ENDPOINT)
    end

    def find_keys(deployment_environment:)
      ServiceConfiguration.find_by(service_id: @service_id, deployment_environment:, name: SERVICE_OUTPUT_JSON_KEY)
    end

    def all
      find_urls('dev').merge(find_keys('dev')).merge(find_urls('production')).find_keys('production')
    end

    def find(id:)
      ServiceConfiguration.find(id:)
    end

    def save
      service_configuration = ServiceConfiguration.find_or_initialize_by(
        service_id: @service_id,
        deployment_environment: @deployment_environment,
        name: @name
      )
      service_configuration.value = @value
      service_configuration.save!
    end

    def update(new_settings)
      @value = new_settings[:value]
      save
    end

    def destroy
      # TODO
      puts 'We will destroy'
    end
  end
end
