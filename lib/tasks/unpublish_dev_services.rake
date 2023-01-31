namespace 'unpublish' do
  desc 'Unpublishes dev services from Test and Live environments.'
  task dev_services: [:environment, 'db:load_config'] do
    UnpublishDevServices.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
