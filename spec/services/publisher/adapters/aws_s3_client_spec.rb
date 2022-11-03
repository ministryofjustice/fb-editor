RSpec.describe Publisher::Adapters::AwsS3Client do
  subject(:aws_s3_client) do
    described_class.new(platform_deployment)
  end
  let(:platform_deployment) { 'TEST_DEV' }

  describe '#upload' do
    let(:body) { { foo: 'bar' } }
    let(:bucket) { 'some-bucket' }
    let(:object_key) { 'some-object-key' }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("AWS_S3_BUCKET_#{platform_deployment}").and_return(bucket)
    end

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
