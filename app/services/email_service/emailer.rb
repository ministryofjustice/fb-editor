require 'aws-sdk-ses'

module EmailService
  class Emailer
    def initialize
      @adapter = if ENV['AWS_SES_ACCESS_KEY_ID'].present?
                   EmailService::Adapters::AwsSesClientV3.new
                 else
                   EmailService::Adapters::MockAmazonAdapter.new
                 end
    end

    def send_mail(opts = {})
      @adapter.send_mail(opts)
    end
  end
end
