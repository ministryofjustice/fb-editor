if Rails.env.development? || Rails.env.test?
  Aws.config.update(
    region: 'us-east-1',
    endpoint: ENV.fetch('AWS_ENDPOINT', 'http://localstack-main:4566'), # Use http://localstack-main:4566 with docker and 'http://localhost.localstack.cloud:4566' without docker
    access_key_id: 'test',
    secret_access_key: 'test',
    force_path_style: true # Crucial for S3 to work properly with LocalStack
  )
end
