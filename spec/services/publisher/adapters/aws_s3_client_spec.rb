RSpec.describe Publisher::Adapters::AwsS3Client do
  subject(:aws_s3_client) do
    described_class.new(
      bucket: bucket,
      access_key_id: 'some-access-key_id',
      secret_access_key: 'some-secret-access-key'
    )
  end

  describe '#upload' do
    let(:body) { { foo: 'bar' } }
    let(:bucket) { 'some-bucket' }
    let(:object_key) { 'some-object-key' }

    it 'should upload an object to s3' do
      expect_any_instance_of(Aws::S3::Client).to receive(:put_object).with(
        body: body,
        bucket: bucket,
        key: object_key
      )
      aws_s3_client.upload(object_key, body)
    end
  end
end
