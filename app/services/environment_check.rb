module EnvironmentCheck
  include ::Publisher::ConfigurationNaming
  LIVE_PRODUCTION = 'live-production'.freeze

  def live_production?(deployment_environment:, platform_environment: ENV['PLATFORM_ENV'])
    "#{platform_environment}-#{deployment_environment}" == LIVE_PRODUCTION
  end
end
