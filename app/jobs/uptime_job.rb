class UptimeJob < ApplicationJob
  queue_as :default

  def perform(service_id:, action:, service_name: nil, host: nil)
    Uptime.new(
      service_id: service_id,
      service_name: service_name,
      host: host,
      adapter: adapter
    ).method(action).call
  end

  def adapter
    if Rails.env.development?
      Uptime::Adapters::Local
    else
      Uptime::Adapters::Pingdom
    end
  end
end
