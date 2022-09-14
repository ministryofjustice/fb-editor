namespace 'from_address' do
  desc 'Syncs From Address status to Editor DB'
  task sync: [:environment, 'db:load_config'] do
    ses = EmailService::Adapters::AwsSesClient.new
    email_identities = ses.list_email_identities.email_identities.select do |id|
      id.identity_type == 'EMAIL_ADDRESS'
    end

    FromAddress.where(status: :pending).each do |record|
      decrypted_email = record.decrypt_email
      email_id = email_identities.find { |i| i.identity_name == decrypted_email }
      record.update!(:status, :verified) if email_id&.sending_enabled
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
