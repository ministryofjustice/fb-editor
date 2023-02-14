class Uptime
  attr_reader :service_id, :check_id, :service_name, :host, :adapter

  def initialize(adapter:, service_id: nil, check_id: nil, service_name: nil, host: nil)
    @service_id = service_id
    @check_id = check_id
    @service_name = service_name
    @host = host
    @adapter = adapter.new
  end

  def create
    if check_exists?
      update
    else
      ActiveSupport::Notifications.instrument('uptime.create') do
        new_check_id = adapter.create(service_name, host, service_id)
        UptimeCheck.new(
          service_id:,
          check_id: new_check_id
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
      adapter.destroy(check_id)
      uptime_check.destroy
    rescue StandardError
      Sentry.capture_mesesage(
        "Unable to delete Uptime Check for service #{uptime_check.service_id}"
      )
    end
  end

  def check_exists?
    uptime_check.present? && adapter.exists?(service_id)
  end

  def uptime_check
    @uptime_check ||= UptimeCheck.find_by(attributes)
  end

  def attributes
    {
      service_id:,
      check_id:
    }.compact
  end
end
