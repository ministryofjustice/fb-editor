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
    TEST_PRODUCTION = 'test-production'.freeze

    def service_metadata
      service.to_json
    end

    def autocomplete_items
      Hash(autocomplete_response['items']).to_json
    end

    def autocomplete_ids
      # This refers to the table row IDs in the MetadataAPI
      autocomplete_response['autocomplete_ids'] || []
    end

    def get_binding
      binding
    end

    delegate :service_name, :created_by, to: :service

    def service_slug
      service_slug_config.presence || service.service_slug
    end

    def external_start_page_url
      external_start_page_config.presence || ''
    end

    def container_port
      Rails.application.config.platform_environments[:common][:container_port]
    end

    def secret_key_base
      SecureRandom.hex(64)
    end

    def strategy_max_surge
      global_service_configuration[:strategy][:max_surge]
    end

    def strategy_max_unavailable
      global_service_configuration[:strategy][:max_unavailable]
    end

    def replicas
      service_namespace_configuration[:hpa][:min_replicas]
    end

    def max_replicas
      service_namespace_configuration[:hpa][:max_replicas]
    end

    def target_cpu_utilisation
      service_namespace_configuration[:hpa][:target_cpu_utilisation]
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
      '300m'
    end

    def resource_limits_memory
      '300Mi'
    end

    def resource_requests_cpu
      '30m'
    end

    def resource_requests_memory
      '128Mi'
    end

    def readiness_initial_delay
      global_service_configuration[:readiness][:initial_delay_seconds]
    end

    def readiness_period
      global_service_configuration[:readiness][:period_seconds]
    end

    def readiness_success_threshold
      global_service_configuration[:readiness][:success_threshold]
    end

    def service_sentry_dsn
      if live_production?
        ENV['SERVICE_SENTRY_DSN_LIVE']
      else
        # test-dev, test-production and live-dev
        ENV['SERVICE_SENTRY_DSN_TEST']
      end
    end

    def service_sentry_csp_url
      if live_production?
        ENV['SERVICE_SENTRY_CSP_URL_LIVE']
      else
        # test-dev, test-production and live-dev
        ENV['SERVICE_SENTRY_CSP_URL_TEST']
      end
    end

    def live_production?
      platform_deployment == LIVE_PRODUCTION
    end

    def dev_production?
      platform_deployment == TEST_PRODUCTION
    end

    def config_map
      service_configuration
        .reject(&:secrets?)
        .reject(&:ms_graph_secrets?)
        .reject(&:do_not_send_submission?)
        .reject(&:do_not_send_confirmation_email?)
        .reject(&:not_in_maintenance_mode?)
        .reject(&:do_not_inject_payment_link?)
        .reject(&:do_not_send_to_graph_api?)
    end

    def secrets
      service_configuration.select(&:secrets?)
    end

    def aws_s3_bucket_name
      ENV["AWS_S3_BUCKET_#{deployment_environment_upcase}"]
    end

    def ms_graph_api_secrets
      graph_secrets = []
      secret_names = %w[MS_ADMIN_APP_ID MS_ADMIN_APP_SECRET MS_OAUTH_URL MS_TENANT_ID]

      secret_names.each do |name|
        config = ServiceConfiguration.find_or_initialize_by(
          service_id:,
          name:,
          deployment_environment:
        )
        config.value = ENV[name].presence || 'default_prevent_validation_error'
        config.save!
        graph_secrets << config
      end

      graph_secrets
    end

    def ms_graph_root_url
      ENV['MS_GRAPH_ROOT_URL'] || 'https://graph.microsoft.com/v1.0/'
    end

    def ms_list_site_id
      ServiceConfiguration.find_by(
        service_id:,
        name: 'MS_LIST_SITE_ID',
        deployment_environment:
      ).decrypt_value || ''
    end

    private

    def service
      @service ||= MetadataPresenter::Service.new(
        MetadataApiClient::Version.find(
          service_id:,
          version_id:
        ).metadata
      )
    end

    def platform_app_url(app_name)
      sprintf(
        Rails.application.config.platform_environments[:common][app_name],
        platform_environment:,
        deployment_environment:
      )
    end

    def global_service_configuration
      @global_service_configuration ||= Rails.application.config.global_service_configuration
    end

    def service_namespace_configuration
      @service_namespace_configuration ||=
        Rails.application.config.service_namespace_configuration[:"#{platform_environment}_#{deployment_environment}"]
    end

    def autocomplete_response
      @autocomplete_response ||= begin
        response = MetadataApiClient::Items.all(service_id:)
        Rails.logger.info(response.errors) if response.errors?

        response.respond_to?(:metadata) ? response.metadata : {}
      end
    end

    def deployment_environment_upcase
      @deployment_environment_upcase ||= deployment_environment.upcase
    end

    def service_slug_config
      ServiceConfiguration.find_by(
        service_id:,
        name: 'SERVICE_SLUG',
        deployment_environment: 'dev'
      )&.decrypt_value
    end

    def external_start_page_config
      ServiceConfiguration.find_by(
        service_id:,
        name: 'EXTERNAL_START_PAGE_URL',
        deployment_environment: 'production'
      )&.decrypt_value
    end
  end
end
