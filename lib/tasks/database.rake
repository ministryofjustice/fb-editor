namespace 'db:sessions' do
  desc 'Trim all sessions from the table'
  task trim: [:environment, 'db:load_config'] do
    ActiveRecord::SessionStore::Session
    .delete_all
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
