require 'aws-sdk-s3'

class Publisher
  module Adapters
    class AwsS3Client
      def initialize(platform_deployment)
        @platform_deployment = platform_deployment
      end

      REGION = 'eu-west-2'.freeze

      def upload(object_key, body)
        Rails.logger.info("Uploading #{object_key} to S3")
        s3.put_object(
          body: body,
          bucket: ENV["AWS_S3_BUCKET_#{platform_deployment}"],
          key: object_key
        )
      end

      private

      attr_reader :platform_deployment

      def s3
        @s3 ||= Aws::S3::Client.new(region: REGION, credentials: credentials)
      end

      def credentials
        Aws::Credentials.new(
          ENV["AWS_S3_ACCESS_KEY_ID_#{platform_deployment}"],
          ENV["AWS_S3_SECRET_ACCESS_KEY_#{platform_deployment}"]
        )
      end
    end
  end
end
