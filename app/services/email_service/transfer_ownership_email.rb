module EmailService
  class TransferOwnershipEmail
    def self.send_email(service_name:, previous_owner:, new_owner:)
      TransferOwnershipMailer.transfer_ownership(
        service_name:, previous_owner:, new_owner:
      ).deliver_later
    end
  end
end
