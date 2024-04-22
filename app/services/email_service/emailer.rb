module EmailService
  class Emailer
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze
    REGION = 'eu-west-1'.freeze
    ENCODING = 'UTF-8'.freeze

    def initialize
      @access_key = ENV['AWS_SES_ACCESS_KEY_ID']
      @secret_access_key = ENV['AWS_SES_SECRET_ACCESS_KEY']
    end

    def send_mail(opts = {})
      ses.send_email({
        from_email_address: DEFAULT_FROM_ADDRESS,
        destination: {
          to_addresses: [opts[:to]]
        },
        content: { # required
          simple: {
            subject: { # required
              data: opts[:subject], # required
              charset: ENCODING
            },
            body: { # required
              text: {
                data: opts[:body], # required
                charset: ENCODING
              },
              html: {
                data: opts[:html], # required
                charset: ENCODING
              }
            }
          }
        }
      })
    end

    private

    attr_reader :access_key, :secret_access_key

    def ses
      Aws::SESV2::Client.new(region: REGION, credentials:)
    end

    def credentials
      Aws::Credentials.new(access_key, secret_access_key)
    end
  end
end
