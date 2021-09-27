Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe(
    'exceeded_total_flow_objects'
  ) do |_name, _start, _finish, _id, payload|
    Rails.logger.info(payload[:message])
  end
end
