class Publisher
  module Adapters
    class CloudPlatform
      class ConfigFilesNotFound < StandardError; end
      class UploadMetadataError < StandardError; end
      attr_reader :service_provisioner

      delegate :service_id,
               :namespace,
               :service_slug,
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

      def completed
        if live_production? && first_published?
          NotificationService.notify(review_message, webhook: ENV['SLACK_REVIEW_WEBHOOK'])
        end
      end

      private

      def published_for_review?
        ServiceConfiguration.find_by(
          service_id:,
          name: 'AWAITING_APPROVAL'
        ).present? &&
          ServiceConfiguration.find_by(
            service_id:,
            name: 'APPROVED_TO_GO_LIVE'
          ).blank? &&
          first_published?
      end

      def first_published?
        PublishService.completed
        .where(
          service_id:,
          deployment_environment:
        ).count == 1
      end

      def message
        "#{service_name} has been published to #{namespace}.\n#{hostname}"
      end

      def review_message
        "#{service_name} has been published for review using the review credentials.\n#{hostname}"
      end

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
