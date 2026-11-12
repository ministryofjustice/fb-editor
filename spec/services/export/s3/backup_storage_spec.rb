require 'rails_helper'

RSpec.describe Export::S3::BackupStorage do
  subject(:backup_storage) { described_class.new(bucket: bucket, s3_client: s3_client) }

  let(:bucket) { 'test-bucket' }
  let(:s3_client) { instance_double(Aws::S3::Client, config: config) }
  let(:config) { double(region: 'eu-west-2') }

  describe '#ensure_bucket!' do
    it 'creates the bucket with location constraint' do
      expect(s3_client).to receive(:create_bucket).with(
        {
          bucket: bucket,
          create_bucket_configuration: { location_constraint: 'eu-west-2' }
        }
      )

      backup_storage.ensure_bucket!
    end

    context 'when bucket is already owned by user' do
      before do
        allow(s3_client).to receive(:create_bucket).and_raise(
          Aws::S3::Errors::BucketAlreadyOwnedByYou.new(nil, 'Bucket already owned')
        )
      end

      it 'rescues the error and returns nil' do
        expect(backup_storage.ensure_bucket!).to be_nil
      end
    end
  end

  describe '#upload' do
    let(:tempfile) { Tempfile.new('test_backup.zip') }
    let(:key) { 'metadata-backups/test.zip' }

    before do
      tempfile.write('zip contents')
      tempfile.rewind
    end

    after do
      tempfile.close
      tempfile.unlink
    end

    it 'uploads the file to S3 with zip content type' do
      expect(s3_client).to receive(:put_object).with(
        bucket: bucket,
        key: key,
        body: kind_of(File),
        content_type: 'application/zip'
      )

      backup_storage.upload(file_path: tempfile.path, key: key)
    end
  end
end
