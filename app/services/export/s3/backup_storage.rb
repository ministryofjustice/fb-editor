# frozen_string_literal: true

module Export
  module S3
    # Thin wrapper around the S3 operations the backup needs.
    class BackupStorage
      DEFAULT_CONTENT_TYPE = 'application/zip'
      attr_reader :bucket

      def initialize(bucket:, s3_client:)
        @bucket = bucket
        @s3_client = s3_client
      end

      def ensure_bucket!
        @s3_client.create_bucket(create_bucket_params)
      rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
        nil # Already exists; nothing to do.
      end

      def upload(file_path:, key:)
        File.open(file_path, 'rb') do |file|
          @s3_client.put_object(
            bucket: bucket,
            key: key,
            body: file,
            content_type: DEFAULT_CONTENT_TYPE
          )
        end
      end

      private

      # Regions other than us-east-1 require an explicit location constraint.
      def create_bucket_params
        { bucket: bucket, create_bucket_configuration: { location_constraint: region } }
      end

      def region
        @s3_client.config.region
      end
    end
  end
end
