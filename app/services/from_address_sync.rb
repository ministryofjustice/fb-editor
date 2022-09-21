class FromAddressSync
  def call
    email_pending.each do |record|
      decrypted_email = record.decrypt_email
      email_id = email_identities.find do |i|
        i.identity_name == decrypted_email
      end
      record.verified! if email_id&.sending_enabled
    end
  end

  private

  def ses
    @ses ||= EmailService::Adapters::AwsSesClient.new
  end

  def email_identities
    @email_identities ||= ses.list_email_identities.email_identities.select do |id|
      id.identity_type == 'EMAIL_ADDRESS'
    end
  end

  def email_pending
    @email_pending ||= FromAddress.where(status: :pending)
  end
end
