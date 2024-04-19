module EmailService
  class Emailer
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def self.send_mail(opts = {})
      ses = Aws::SESV2::Client.new(region: 'eu-west-1')
      encoding = 'UTF-8'

      ses.send_email({
        from_email_address: DEFAULT_FROM_ADDRESS,
        destination: {
          to_addresses: opts[:to]
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
    rescue Aws::SES::Errors::ServiceError => e
      Rails.logger.debug "Email not sent. Error message: #{e}"
    end
  end
end
