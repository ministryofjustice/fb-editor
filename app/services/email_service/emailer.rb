module EmailService
  class Emailer
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def self.send_mail(opts = {})
      ses = Aws::SESV2::Client.new(region: 'eu-west-1')

      ses.send_email({
        from_email_address: DEFAULT_FROM_ADDRESS,
        destination: {
          to_addresses: opts[:to]
        },
        content: { # required
          simple: {
            subject: { # required
              data: opts[:subject], # required
              charset: 'Charset'
            },
            body: { # required
              text: {
                data: opts[:body], # required
                charset: 'Charset'
              },
              html: {
                data: opts[:html], # required
                charset: 'Charset'
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
