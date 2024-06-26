class Publisher
  module Adapters
    class CloudPlatform
      class ConfigFilesNotFound < StandardError; end
      class UploadMetadataError < StandardError; end
      attr_reader :service_provisioner

      delegate :service_id,
               :namespace,
               :service_slug,
               :external_start_page_url,
               :hostname,
               :service_name,
               :deployment_environment,
               :live_production?,
               :dev_production?,
               to: :service_provisioner

      def initialize(service_provisioner)
        @service_provisioner = service_provisioner
      end

      def pre_publishing
        ::Publisher::Utils::ServiceMetadataFiles.new(
          service_provisioner,
          aws_s3_adapter
        ).upload

        ::Publisher::Utils::KubernetesConfiguration.new(
          service_provisioner
        ).generate(destination: create_config_dir)
      rescue Aws::S3::Errors::ServiceError => e
        Sentry.capture_exception(e)
        raise UploadMetadataError, "Failed to upload metadata for #{service_id}"
      end

      def publishing
        if config_dir? && config_files?
          Utils::KubeControl.execute(
            "apply -f #{config_dir}", namespace:
          )
        else
          raise ConfigFilesNotFound, "Config files not found in #{config_dir}"
        end
      end

      def post_publishing
        Utils::KubeControl.execute(
          "rollout restart deployment #{service_slug}",
          namespace:
        )
        Utils::KubeControl.execute(
          "rollout status deployment #{service_slug}",
          namespace:
        )
      end

      def completed; end

      private

      def create_config_dir
        FileUtils.mkdir_p(config_dir)
      end

      def config_dir
        Rails.root.join('tmp', 'publisher', "#{service_id}-#{service_slug}")
      end

      def config_dir?
        File.exist?(config_dir)
      end

      def config_files?
        Dir["#{config_dir}/*"].any?
      end

      def aws_s3_adapter
        Publisher::Adapters::AwsS3Client.new(
          bucket: service_provisioner.aws_s3_bucket_name
        )
      end
    end
  end
end
