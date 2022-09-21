namespace 'from_address' do
  desc 'Syncs From Address status to Editor DB'
  task sync: [:environment, 'db:load_config'] do
    FromAddressSync.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
