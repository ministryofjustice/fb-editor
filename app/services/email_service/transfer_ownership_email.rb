module EmailService
  class TransferOwnershipEmail
    DEFAULT_FROM_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze
    attr_accessor :service_name, :previous_owner, :new_owner

    def initialize(service_name:, previous_owner:, new_owner:)
      @service_name = service_name
      @previous_owner = previous_owner
      @new_owner = new_owner
    end

    def send_email
      emailer.send_mail(
        from: DEFAULT_FROM_ADDRESS,
        to: @new_owner,
        raw_message: raw_message.to_s
      )
    end

    def raw_message
      EmailService::TransferRawMessage.new(
        from: DEFAULT_FROM_ADDRESS, to: new_owner, previous_owner:, service_name:
      )
    end

    def emailer
      EmailService::Emailer.new
    end
  end
end
