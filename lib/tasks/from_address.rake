namespace 'from_address' do
  desc 'Syncs From Address status to Editor DB'
  task sync: [:environment, 'db:load_config'] do
    FromAddressSync.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  desc "Update default email to 'no-reply-moj-forms'"
  task update_email: [:environment, 'db:load_config'] do
    FromAddress.all.each do |record|
      if record.email_address == 'moj-forms@digital.justice.gov.uk'
        record.email = ''
        record.save!
      end
    end

  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
