module EmailService
  class Emailer
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def self.send_mail(opts = {})
      ses = Aws::SESV2::Client.new(region: 'eu-west-1')

      ses.send_email(
        subject: opts[:subject],
        from: DEFAULT_FROM_ADDRESS,
        to: opts[:to],
        raw_message: opts[:raw_message]
      )
    end
  end
end
