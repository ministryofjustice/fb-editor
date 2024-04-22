module EmailService
  class Emailer
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def initialize
      @access_key = ENV['AWS_SES_ACCESS_KEY_ID']
      @secret_access_key = ENV['AWS_SES_SECRET_ACCESS_KEY']
    end

    def self.send_mail(opts = {})
      credentials = Aws::Credentials.new(access_key, secret_access_key)
      ses = Aws::SESV2::Client.new(region: 'eu-west-1', credentials:)
      encoding = 'UTF-8'

      ses.send_email({
        from_email_address: DEFAULT_FROM_ADDRESS,
        destination: {
          to_addresses: [opts[:to]]
        },
        content: { # required
          simple: {
            subject: { # required
              data: opts[:subject], # required
              charset: encoding
            },
            body: { # required
              text: {
                data: opts[:body], # required
                charset: encoding
              },
              html: {
                data: opts[:html], # required
                charset: encoding
              }
            }
          },
          raw: {
            data: opts[:raw] # required
          }
        }
      })
    end
  end
end
