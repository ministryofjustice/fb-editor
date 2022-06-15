require 'securerandom'

class Publisher
  class ServiceProvisioner
    include ActiveModel::Model
    include ::Publisher::Utils::Hostname
    include ::Publisher::ConfigurationNaming

    attr_accessor :service_id,
                  :version_id,
                  :platform_environment,
                  :deployment_environment,
                  :service_configuration

    validates :service_id,
              :version_id,
              :platform_environment,
              :deployment_environment,
              :service_configuration,
              presence: true

    validates :service_configuration, private_public_key: true

    LIVE_PRODUCTION = 'live-production'.freeze

    def service_metadata
      service.to_json.inspect
    end

    def get_binding
      binding
    end

    delegate :service_slug, to: :service

    delegate :service_name, to: :service

    def container_port
      Rails.application.config.platform_environments[:common][:container_port]
    end

    def secret_key_base
      SecureRandom.hex(64)
    end

    def replicas
      service_hpa[:min_replicas]
    end

    def max_replicas
      service_hpa[:max_replicas]
    end

    def target_cpu_utilisation
      service_hpa[:target_cpu_utilisation]
    end

    def user_datastore_url
      platform_app_url(:user_datastore_url)
    end

    def submitter_url
      platform_app_url(:submitter_url)
    end

    def user_filestore_url
      platform_app_url(:user_filestore_url)
    end

    def submission_encryption_key
      ENV['SUBMISSION_ENCRYPTION_KEY']
    end

    def resource_limits_cpu
      '150m'
    end

    def resource_limits_memory
      '300Mi'
    end

    def resource_requests_cpu
      '10m'
    end

    def resource_requests_memory
      '128Mi'
    end

    def service_sentry_dsn
      if live_production?
        ENV['SERVICE_SENTRY_DSN_LIVE']
      else
        # test-dev, test-production and live-dev
        ENV['SERVICE_SENTRY_DSN_TEST']
      end
    end

    def live_production?
      platform_deployment == LIVE_PRODUCTION
    end

    def config_map
      service_configuration.reject(&:secrets?).reject(&:do_not_send_submission?)
    end

    def secrets
      service_configuration.select(&:secrets?)
    end

    private

    def service
      @service ||= MetadataPresenter::Service.new(
        MetadataApiClient::Version.find(
          service_id: service_id,
          version_id: version_id
        ).metadata
      )
    end

    def platform_app_url(app_name)
      sprintf(
        Rails.application.config.platform_environments[:common][app_name],
        platform_environment: platform_environment,
        deployment_environment: deployment_environment
      )
    end

    def service_hpa
      @service_hpa ||=
        Rails.application.config.services_hpa[:"#{platform_environment}_#{deployment_environment}"]
    end
  end
end
