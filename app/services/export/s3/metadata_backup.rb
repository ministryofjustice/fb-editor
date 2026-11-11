# frozen_string_literal: true

require 'tmpdir'

module Export
  module S3
    # Orchestrates a full metadata backup: reads every service version from the
    # Metadata API, packs it into a ZIP archive and uploads it to S3.
    #
    #   Export::S3::MetadataBackup.call(bucket: BUCKET_NAME, services_per_page: SERVICES_TO_FETCH_PER_PAGE) # => "metadata-backups/metadata-backup-20261102T120000Z.zip"
    class MetadataBackup
      DEFAULT_PER_PAGE = 100
      DEFAULT_S3_PREFIX = 'metadata-backups'
      REGION = 'eu-west-2'

      def self.call(**options)
        new(**options).call
      end

      def initialize(bucket: ENV.fetch('METADATA_BACKUP_BUCKET'), services_per_page: DEFAULT_PER_PAGE)
        @source = MetadataSource.new(per_page: services_per_page)
        @archive_writer = ZipArchiveWriter.new
        @storage = BackupStorage.new(bucket: bucket, s3_client: Aws::S3::Client.new(region: REGION))
      end

      # Runs the backup and returns the S3 object key.
      def call
        @storage.ensure_bucket!

        key = build_key
        Dir.mktmpdir('metadata_backup') do |dir|
          zip_path = File.join(dir, 'metadata_backup.zip')

          @archive_writer.write(zip_path, @source.each_service_version)
          @storage.upload(file_path: zip_path, key: key)
        end

        Rails.logger.info("Metadata backup uploaded to s3://#{@storage.bucket}/#{key}")
        key
      end

      private

      def build_key
        timestamp = Time.zone.now.utc.strftime('%Y%m%dT%H%M%S')

        [DEFAULT_S3_PREFIX, "metadata-backup-#{timestamp}.zip"].reject(&:empty?).join('/')
      end
    end
  end
end
