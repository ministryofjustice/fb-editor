class Publisher
  module ConfigurationNaming
    def config_map_name
      "fb-#{service_slug}-config-map"
    end

    def ingress
      "#{service_slug}-ingress-new"
    end

    def service_monitor_network_policy_name
      "formbuilder-form-#{service_slug}-service-monitor-ingress-#{platform_deployment}"
    end

    def secret_name
      "fb-#{service_slug}-secrets"
    end

    def service_monitor_name
      "formbuilder-form-#{service_slug}-service-monitor-#{platform_deployment}"
    end

    def namespace
      sprintf(
        Rails.application.config.platform_environments[:common][:namespace],
        platform_environment: platform_environment,
        deployment_environment: deployment_environment
      )
    end

    def platform_deployment
      "#{platform_environment}-#{deployment_environment}"
    end
  end
end
