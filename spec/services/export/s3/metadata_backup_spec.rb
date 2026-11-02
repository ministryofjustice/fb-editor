# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::S3::MetadataBackup, type: :service do
  subject(:backup) do
    described_class.new(
      bucket: bucket
    )
  end

  let(:bucket) { 'test-backup-bucket' }
  let(:storage) { instance_double(Export::S3::BackupStorage, bucket: bucket) }
  let(:source) { instance_double(Export::S3::MetadataSource) }
  let(:archive_writer) { instance_double(Export::S3::ZipArchiveWriter) }
  let(:fixed_time) { Time.zone.parse('2026-11-04 12:30:00 UTC') }
  let(:service_enum) { [].to_enum }

  describe '.call' do
    it 'instantiates and calls the service' do
      instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(bucket: 'custom-bucket').and_return(instance)
      allow(instance).to receive(:call).and_return('key.zip')

      expect(described_class.call(bucket: 'custom-bucket')).to eq('key.zip')
    end
  end

  describe '#call' do
    before do
      allow(Export::S3::BackupStorage).to receive(:new)
        .with(bucket: bucket, s3_client: an_instance_of(Aws::S3::Client))
        .and_return(storage)
      allow(Export::S3::MetadataSource).to receive(:new)
        .with(per_page: described_class::DEFAULT_PER_PAGE, query: described_class::DEFAULT_QUERY)
        .and_return(source)
      allow(Export::S3::ZipArchiveWriter).to receive(:new)
        .and_return(archive_writer)

      allow(storage).to receive(:ensure_bucket!)
      allow(storage).to receive(:upload)
      allow(source).to receive(:each_service_version).and_return(service_enum)
      allow(archive_writer).to receive(:write)

      allow(Time.zone).to receive(:now).and_return(fixed_time)
    end

    it 'ensures the bucket exists, writes archive, uploads to S3, logs message, and returns object key' do
      expected_key = 'metadata-backups/metadata-backup-20261104T123000Z.zip'

      expect(storage).to receive(:ensure_bucket!)
      expect(archive_writer).to receive(:write).with(
        an_instance_of(String),
        service_enum
      ) do |zip_path, _enum|
        expect(zip_path).to end_with('metadata_backup.zip')
      end

      expect(storage).to receive(:upload).with(
        file_path: an_instance_of(String),
        key: expected_key
      )

      expect(Rails.logger).to receive(:info).with("Metadata backup uploaded to s3://#{bucket}/#{expected_key}")

      result = backup.call
      expect(result).to eq(expected_key)
    end
  end

  describe '#initialize defaults' do
    context 'when no explicit dependencies are passed' do
      it 'initializes with default options without raising errors' do
        expect { described_class.new }.not_to raise_error
      end

      it 'uses default bucket when METADATA_BACKUP_BUCKET is not set' do
        instance = described_class.new
        expect(instance.instance_variable_get(:@storage).bucket).to eq('formbuilder')
      end

      it 'uses ENV bucket when METADATA_BACKUP_BUCKET is present' do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch)
          .with('METADATA_BACKUP_BUCKET', Export::S3::MetadataBackup::DEFAULT_S3_BUCKET)
          .and_return('env-bucket')

        instance = described_class.new
        expect(instance.instance_variable_get(:@storage).bucket).to eq('env-bucket')
      end
    end
  end
end
