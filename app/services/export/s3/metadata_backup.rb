# frozen_string_literal: true

require 'tmpdir'

module Export
  module S3
    # Orchestrates a full metadata backup: reads every service version from the
    # Metadata API, packs it into a ZIP archive and uploads it to S3.
    #
    #   Export::S3::MetadataBackup.call(bucket: BUCKET_NAME, services_per_page: SERVICES_TO_FETCH_PER_PAGE) # => "metadata-backups/metadata-backup-20261102T120000Z.zip"
    class MetadataBackup
      class Error < StandardError; end

      DEFAULT_PER_PAGE  = 100
      DEFAULT_S3_PREFIX = 'metadata-backups'
      REGION            = 'eu-west-2'
      ZIP_FILENAME      = 'metadata_backup.zip'

      attr_reader :bucket

      def self.call(**options)
        new(**options).call
      end

      def initialize(bucket: ENV.fetch('METADATA_BACKUP_BUCKET'), services_per_page: DEFAULT_PER_PAGE, ensure_bucket: false)
        @bucket = bucket
        @source = MetadataSource.new(per_page: services_per_page)
        @archive_writer = ZipArchiveWriter.new
        @storage = BackupStorage.new(bucket: bucket, s3_client: Aws::S3::Client.new(region: REGION))
        @ensure_bucket = ensure_bucket
      end

      # Runs the backup and returns the S3 object key.
      def call
        @storage.ensure_bucket! if @ensure_bucket

        key = build_key
        log(:info, "Starting metadata backup to s3://#{bucket}/#{key}")

        Dir.mktmpdir('metadata_backup') do |dir|
          zip_path = File.join(dir, ZIP_FILENAME)

          @archive_writer.write(zip_path, @source.each_service_version)

          size = File.size?(zip_path)
          raise Error, 'Archive is empty, refusing to upload' unless size

          @storage.upload(file_path: zip_path, key: key)
          size
        end

        log(:info, "Metadata backup uploaded to s3://#{@storage.bucket}/#{key}")
        key
      end

      private

      def build_key
        timestamp = Time.current.utc.strftime('%Y%m%dT%H%M%SZ')
        filename  = "metadata-backup-#{timestamp}.zip"

        [DEFAULT_S3_PREFIX, filename].reject(&:empty?).join('/')
      end

      def log(level, message)
        Rails.logger.public_send(level, "[MetadataBackup] #{message}")
      end
    end
  end
end
