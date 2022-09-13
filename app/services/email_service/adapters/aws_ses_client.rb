require 'aws-sdk-sesv2'

module EmailService
  module Adapters
    class AwsSesClient
      def initialize
        @access_key = ENV['AWS_SES_ACCESS_KEY_ID']
        @secret_access_key = ENV['AWS_SES_SECRET_ACCESS_KEY']
      end

      REGION = 'eu-west-1'.freeze

      def list_email_identities
        ses.list_email_identities(page_size: 1000)
      end

      def get_email_identity(identity)
        ses.get_email_identity(email_identity: identity)
      rescue Aws::SESV2::Errors::NotFoundException
        nil
      end

      def create_email_identity(identity)
        ses.create_email_identity(email_identity: identity)
      end

      def delete_email_identity(identity)
        ses.delete_email_identity(email_identity: identity)
      end

      private

      attr_reader :access_key, :secret_access_key

      def ses
        @ses ||= Aws::SESV2::Client.new(region: REGION, credentials: credentials)
      end

      def credentials
        Aws::Credentials.new(access_key, secret_access_key)
      end
    end
  end
end
