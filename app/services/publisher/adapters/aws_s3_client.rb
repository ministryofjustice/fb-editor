require 'aws-sdk-s3'

class Publisher
  module Adapters
    class AwsS3Client
      def initialize(bucket:, access_key_id:, secret_access_key:)
        @bucket = bucket
        @access_key_id = access_key_id
        @secret_access_key = secret_access_key
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

      attr_reader :bucket, :access_key_id, :secret_access_key

      def s3
        @s3 ||= Aws::S3::Client.new(region: REGION, credentials:)
      end

      def credentials
        Aws::Credentials.new(access_key_id, secret_access_key)
      end
    end
  end
end
