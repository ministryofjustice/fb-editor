# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::S3::BackupStorage, type: :service do
  subject(:backup_storage) { described_class.new(bucket: bucket, s3_client: s3_client) }

  let(:bucket) { 'test-backup-bucket' }
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:s3_config) { double('s3_config', region: region) }
  let(:region) { 'eu-west-2' }

  before do
    allow(s3_client).to receive(:config).and_return(s3_config)
  end

  describe '#bucket' do
    it 'returns the configured bucket name' do
      expect(backup_storage.bucket).to eq('test-backup-bucket')
    end
  end

  describe '#ensure_bucket!' do
    context 'when region is eu-west-2' do
      let(:region) { 'eu-west-2' }

      it 'creates the bucket with location constraint configuration' do
        expect(s3_client).to receive(:create_bucket) do |params|
          expect(params).to eq(
            bucket: bucket,
            create_bucket_configuration: { location_constraint: 'eu-west-2' }
          )
        end

        backup_storage.ensure_bucket!
      end
    end

    context 'when bucket already exists and is owned by the user' do
      before do
        allow(s3_client).to receive(:create_bucket).and_raise(
          Aws::S3::Errors::BucketAlreadyOwnedByYou.new(Seahorse::Client::RequestContext.new, 'Bucket already owned')
        )
      end

      it 'rescues the exception and returns nil' do
        expect { backup_storage.ensure_bucket! }.not_to raise_error
        expect(backup_storage.ensure_bucket!).to be_nil
      end
    end
  end

  describe '#upload' do
    let(:tempfile) { Tempfile.new('test_upload') }
    let(:key) { 'metadata-backups/test.zip' }

    before do
      tempfile.write('dummy zip content')
      tempfile.flush
    end

    after do
      tempfile.close
      tempfile.unlink
    end

    it 'uploads the file to S3 with content_type application/zip' do
      expect(s3_client).to receive(:put_object) do |params|
        expect(params[:bucket]).to eq(bucket)
        expect(params[:key]).to eq(key)
        expect(params[:content_type]).to eq('application/zip')
        expect(params[:body]).to be_a(File)
        expect(params[:body].read).to eq('dummy zip content')
      end

      backup_storage.upload(file_path: tempfile.path, key: key)
    end
  end
end
