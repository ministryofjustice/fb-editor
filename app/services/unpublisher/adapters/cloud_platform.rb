class Unpublisher
  module Adapters
    class CloudPlatform
      include ActiveModel::Model
      include ::Publisher::ConfigurationNaming
      attr_accessor :publish_service, :platform_environment, :service_slug

      CONFIGURATIONS = %w[
        configmap
        deployment
        hpa
        ingress
        networkpolicy
        secret
        service
        servicemonitor
      ].freeze
      NOT_FOUND = 'Error from server (NotFound)'.freeze

      def unpublishing
        publish_service.update!(status: 'unpublishing')
        CONFIGURATIONS.each do |config|
          ActiveSupport::Notifications.instrument("unpublisher.#{config}") do
            config_name = send(config)
            if config_present?(config:, name: config_name)
              removal_service.delete(config:, name: config_name)
            end
          end
        end
      end

      def unpublished
        publish_service.update!(status: 'unpublished')
        NotificationService.notify(message)
      end

      private

      alias_method :deployment, :service_slug
      alias_method :hpa, :service_slug
      alias_method :service, :service_slug
      alias_method :configmap, :config_map_name
      alias_method :networkpolicy, :service_monitor_network_policy_name
      alias_method :secret, :secret_name
      alias_method :servicemonitor, :service_monitor_name
      delegate :deployment_environment, to: :publish_service

      def config_present?(config:, name:)
        Publisher::Utils::Shell.output_of(
          '$(which kubectl)',
          "get #{config} #{name} -n #{namespace}"
        )
      rescue Publisher::Utils::Shell::CmdFailedError => e
        return false if e.message.include?(NOT_FOUND)

        raise e
      end

      def removal_service
        @removal_service ||= K8sConfigRemovalService.new(namespace:)
      end

      def message
        "#{service_slug} has been unpublished from #{namespace}"
      end
    end
  end
end
