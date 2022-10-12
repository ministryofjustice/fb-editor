namespace 'unpublish' do
  desc 'Unpublishes services from a given environment'
  task test_services: [:environment, 'db:load_config'] do
    return if ENV['PLATFORM_ENV'] == 'live'

    UnpublishTestServices.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
