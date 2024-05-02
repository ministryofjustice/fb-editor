module EmailService
  module Adapters
    class AwsSesClientV3
      REGION = 'eu-west-1'.freeze

      def initialize
        @access_key = ENV['AWS_SES_ACCESS_KEY_ID']
        @secret_access_key = ENV['AWS_SES_SECRET_ACCESS_KEY']
      end

      def send_mail(opts = {})
        ses.send_raw_email({
          source: opts[:from],
          destinations: [opts[:to]],
          raw_message: {
            data: opts[:raw_message]
          }
        })
      rescue Aws::SES::Errors::ServiceError => e
        Rails.logger.debug "Email not sent. Error message: #{e}"
      end

      private

      attr_reader :access_key, :secret_access_key

      def ses
        Aws::SES::Client.new(region: REGION, credentials:)
      end

      def credentials
        Aws::Credentials.new(access_key, secret_access_key)
      end
    end
  end
end
