require 'aws-sdk-s3'

class Publisher
  module Adapters
    class AwsS3Client
      attr_reader :bucket

      def initialize(bucket:)
        @bucket = bucket
      end

      REGION = 'eu-west-2'.freeze

      def upload(object_key, body)
        Rails.logger.info("Uploading #{object_key} to S3")
        s3.put_object(
          body:,
          bucket:,
          key: object_key
        )
      end

      private

      def s3
        @s3 ||= Aws::S3::Client.new(region: REGION)
      end
    end
  end
end
