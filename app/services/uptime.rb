class Uptime
  attr_reader :service_id, :service_name, :host, :adapter

  def initialize(service_id:, service_name:, host:, adapter:)
    @service_id = service_id
    @service_name = service_name
    @host = host
    @adapter = adapter.new
  end

  def create
    if uptime_check.present?
      update
    else
      ActiveSupport::Notifications.instrument('uptime.create') do
        response = adapter.create(service_name, host)
        UptimeCheck.new(
          service_id: service_id,
          check_id: response['check']['id']
        ).save
      end
    end
  end

  def update
    ActiveSupport::Notifications.instrument('uptime.update') do
      adapter.update(uptime_check.check_id, service_name, host)
    end
  end

  def destroy
    ActiveSupport::Notifications.instrument('uptime.destroy') do
      adapter.destroy(uptime_check.check_id)
      uptime_check.destroy
    end
  end

  def uptime_check
    @uptime_check ||= UptimeCheck.find_by(service_id: service_id)
  end
end
