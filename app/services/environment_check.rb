module EnvironmentCheck
  LIVE_PRODUCTION = 'live-production'.freeze

  def live_production?(platform_environment: ENV['PLATFORM_ENV'])
    platform_environment == LIVE_PRODUCTION
  end
end
