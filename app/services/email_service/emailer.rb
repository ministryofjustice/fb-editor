require 'aws-sdk-ses'

module EmailService
  class Emailer
    REGION = 'eu-west-1'.freeze
    ENCODING = 'UTF-8'.freeze

    def initialize
      @access_key = ENV['AWS_SES_ACCESS_KEY_ID']
      @secret_access_key = ENV['AWS_SES_SECRET_ACCESS_KEY']
    end

    def send_mail(opts = {})
      ses.send_email({
        destination: {
          to_addresses: [opts[:to]]
        },
        message: {
          body: {
            html: {
              charset: ENCODING,
              data: opts[:html]
            },
            text: {
              charset: ENCODING,
              data: opts[:body]
            }
          },
          subject: {
            charset: ENCODING,
            data: opts[:subject]
          }
        },
        source: opts[:from]
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
