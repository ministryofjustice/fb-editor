require 'rails_helper'

RSpec.describe Export::S3::MetadataBackup do
  subject(:backup) do
    described_class.new(
      bucket: bucket,
      services_per_page: per_page,
      ensure_bucket: ensure_bucket
    )
  end

  let(:bucket) { 'custom-backup-bucket' }
  let(:per_page) { 50 }
  let(:ensure_bucket) { false }

  let(:source_mock) { instance_double(Export::S3::MetadataSource) }
  let(:archive_writer_mock) { instance_double(Export::S3::ZipArchiveWriter) }
  let(:storage_mock) { instance_double(Export::S3::BackupStorage, bucket: bucket) }
  let(:enum_mock) { double('Enumerator') }

  before do
    allow(Export::S3::MetadataSource).to receive(:new).with(per_page: per_page).and_return(source_mock)
    allow(Export::S3::ZipArchiveWriter).to receive(:new).and_return(archive_writer_mock)
    allow(Export::S3::BackupStorage).to receive(:new).with(
      bucket: bucket,
      s3_client: kind_of(Aws::S3::Client)
    ).and_return(storage_mock)
  end

  describe '.call' do
    it 'initializes an instance with options and calls #call' do
      backup_instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(bucket: bucket).and_return(backup_instance)
      expect(backup_instance).to receive(:call).and_return('key.zip')

      expect(described_class.call(bucket: bucket)).to eq('key.zip')
    end
  end

  describe '#call' do
    let(:frozen_time) { Time.zone.parse('2026-11-12T00:35:00Z') }
    let(:expected_key) { 'metadata-backups/metadata-backup-20261112T003500Z.zip' }

    it 'coordinates the metadata export, archive creation, and upload to S3' do
      travel_to frozen_time do
        expect(source_mock).to receive(:each_service_version).and_return(enum_mock)
        expect(archive_writer_mock).to receive(:write).with(
          satisfy { |path| path.end_with?('metadata_backup.zip') },
          enum_mock
        ) do |zip_path, _|
          File.write(zip_path, 'fake-zip-data')
        end
        expect(storage_mock).to receive(:upload).with(
          file_path: satisfy { |path| path.end_with?('metadata_backup.zip') },
          key: expected_key
        )
        expect(Rails.logger).to receive(:info).with("[MetadataBackup] Starting metadata backup to s3://#{bucket}/#{expected_key}")
        expect(Rails.logger).to receive(:info).with("[MetadataBackup] Metadata backup uploaded to s3://#{bucket}/#{expected_key}")

        key = backup.call
        expect(key).to eq(expected_key)
      end
    end

    context 'when ensure_bucket is true' do
      let(:ensure_bucket) { true }

      it 'calls ensure_bucket! on storage' do
        travel_to frozen_time do
          expect(storage_mock).to receive(:ensure_bucket!)
          allow(source_mock).to receive(:each_service_version).and_return(enum_mock)
          allow(archive_writer_mock).to receive(:write) do |zip_path, _|
            File.write(zip_path, 'fake-zip-data')
          end
          allow(storage_mock).to receive(:upload)

          expect(backup.call).to eq(expected_key)
        end
      end
    end

    context 'when zip archive is empty or 0 bytes' do
      it 'raises Error without uploading' do
        travel_to frozen_time do
          allow(source_mock).to receive(:each_service_version).and_return(enum_mock)
          allow(archive_writer_mock).to receive(:write) # does not write any content to file
          expect(storage_mock).not_to receive(:upload)

          expect {
            backup.call
          }.to raise_error(Export::S3::MetadataBackup::Error, 'Archive is empty, refusing to upload')
        end
      end
    end

    context 'with default bucket from ENV' do
      subject(:default_backup) { described_class.new }

      around do |example|
        old_val = ENV['METADATA_BACKUP_BUCKET']
        ENV['METADATA_BACKUP_BUCKET'] = 'env-bucket'
        example.run
      ensure
        ENV['METADATA_BACKUP_BUCKET'] = old_val
      end

      before do
        allow(Export::S3::MetadataSource).to receive(:new).with(per_page: 100).and_return(source_mock)
        allow(Export::S3::BackupStorage).to receive(:new).with(
          bucket: 'env-bucket',
          s3_client: kind_of(Aws::S3::Client)
        ).and_return(storage_mock)
        allow(storage_mock).to receive(:bucket).and_return('env-bucket')
      end

      it 'uses the bucket from ENV and default per_page' do
        travel_to frozen_time do
          allow(source_mock).to receive(:each_service_version).and_return(enum_mock)
          allow(archive_writer_mock).to receive(:write) do |zip_path, _|
            File.write(zip_path, 'fake-zip-data')
          end
          allow(storage_mock).to receive(:upload)

          expect(default_backup.call).to eq(expected_key)
        end
      end
    end
  end
end
