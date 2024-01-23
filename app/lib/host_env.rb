module HostEnv
  # Update if more environments are needed
  NAMED_ENVIRONMENTS = [
    LOCAL = 'local'.freeze,
    TEST = 'test'.freeze, # formbuilder-saas-test
    LIVE = 'live'.freeze  # formbuilder-saas-live
  ].freeze

  class << self
    NAMED_ENVIRONMENTS.each { |name| delegate "#{name}?", to: :inquiry }

    def env_name
      return LOCAL if Rails.env.development? || Rails.env.test?

      ENV.fetch('PLATFORM_ENV')
    end

    private

    def inquiry
      env_name.inquiry
    end
  end
end
