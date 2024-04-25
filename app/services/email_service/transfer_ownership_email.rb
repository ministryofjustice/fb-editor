module EmailService
  class TransferOwnershipEmail
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def self.send_email(service_name:, previous_owner:, new_owner:)
      raw_message = EmailService::TransferRawMessage.new(
        from: DEFAULT_FROM_ADDRESS, to: new_owner, previous_owner:, service_name:
      )

      emailer = EmailService::Emailer.new
      emailer.send_mail(
        from: DEFAULT_FROM_ADDRESS,
        to: new_owner,
        raw_message: raw_message.to_s
      )
    end
  end
end
