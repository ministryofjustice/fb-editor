module EmailService
  class TransferOwnershipEmail
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def self.send_email(service_name:, previous_owner:, new_owner:)
      emailer = EmailService::Emailer.new

      body = I18n.t('default_values.transfer_ownership_email.body',
                    service_name:,
                    previous_owner:,
                    href_signin: I18n.t('default_values.transfer_ownership_email.href_signin'),
                    href_contact: I18n.t('default_values.transfer_ownership_email.href_contact'))

      emailer.send_mail(
        from: DEFAULT_FROM_ADDRESS,
        to: new_owner,
        subject: I18n.t('default_values.transfer_ownership_email.subject'),
        body:,
        html: body
      )
    end
  end
end
