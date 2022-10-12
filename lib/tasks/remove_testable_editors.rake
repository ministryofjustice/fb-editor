namespace 'remove' do
  desc 'Removes any testable editors whose branches have been merged and deleted from remote'
  task testable_editors: [:environment] do
    TestableEditorRemover.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  desc 'Removes any non moj forms team test services configurations'
  task test_services_configs: [:environment] do
    return if ENV['PLATFORM_ENV'] == 'live'

    TestServicesConfigsRemover.new.call
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
