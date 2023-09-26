namespace 'test' do
  desc 'Prints team emails'
  task print_team_emails: [:environment] do
    TeamEmailPrinter.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
