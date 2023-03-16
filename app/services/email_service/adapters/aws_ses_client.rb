require 'aws-sdk-sesv2'

module EmailService
  module Adapters
    class AwsSesClient
      # DEPRECATED: Since the release of Reply-To feature we have no use for this adapter.
      # We have decided to deprecate as we may need this client in future for validation purposes.
      def initialize
        @access_key = ENV['AWS_SES_ACCESS_KEY_ID']
        @secret_access_key = ENV['AWS_SES_SECRET_ACCESS_KEY']
      end

      REGION = 'eu-west-1'.freeze

      def list_email_identities
        call(:list_email_identities, { page_size: 1000 })
      end

      def get_email_identity(identity)
        call(:get_email_identity, { email_identity: identity })
      rescue EmailServiceNotFoundError
        nil
      end

      def create_email_identity(identity)
        call(:create_email_identity, { email_identity: identity })
      end

      def delete_email_identity(identity)
        call(:delete_email_identity, { email_identity: identity })
      rescue EmailServiceNotFoundError
        nil
      end

      private

      attr_reader :access_key, :secret_access_key

      def ses
        @ses ||= Aws::SESV2::Client.new(region: REGION, credentials:)
      end

      def credentials
        Aws::Credentials.new(access_key, secret_access_key)
      end

      def call(name, attrs)
        ses.public_send(name, attrs)
      rescue Aws::SESV2::Errors::NotFoundException
        raise EmailServiceNotFoundError
      rescue Aws::SESV2::Errors::ServiceError
        raise EmailServiceError
      end
    end
  end
end
