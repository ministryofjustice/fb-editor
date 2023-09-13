RSpec.describe Publisher::Adapters::AwsS3Client do
  subject(:aws_s3_client) do
    described_class.new(
      bucket:
    )
  end

  describe '#upload' do
    let(:body) { { foo: 'bar' } }
    let(:bucket) { 'some-bucket' }
    let(:object_key) { 'some-object-key' }

    it 'should upload an object to s3' do
      # stub the token requests that the pod service account makes
      stub_request(:put, 'http://169.254.169.254/latest/api/token')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'aws-sdk-ruby3/3.181.0',
          'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
        }
      )
      .to_return(status: 200, body: '', headers: {})
      stub_request(:get, 'http://169.254.169.254/latest/meta-data/iam/security-credentials/')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'aws-sdk-ruby3/3.181.0'
        }
      )
      .to_return(status: 200, body: '', headers: {})

      expect_any_instance_of(Aws::S3::Client).to receive(:put_object).with(
        body:,
        bucket:,
        key: object_key
      )
      aws_s3_client.upload(object_key, body)
    end
  end
end
