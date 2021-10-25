Rails.application.reloader.to_prepare do
  [
    Unpublisher::MAIN,
    Unpublisher::STEPS,
    Unpublisher::Adapters::CloudPlatform::CONFIGURATIONS
  ].flatten.each do |step|
    event_name = step.include?('unpublisher') ? step : "unpublisher.#{step}"

    ActiveSupport::Notifications.subscribe(event_name) do |name, start, finish, _, _|
      duration = finish - start
      Rails.logger.info("Event '#{name}' duration: (%.3f s)" % [duration])
    end
  end
end
