class HealthController < ActionController::API
  # used by liveness probe
  def show
    render plain: 'healthy'
  end

  def readiness
    render plain: 'ready'
  end
end
