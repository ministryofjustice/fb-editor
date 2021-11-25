class Publisher
  class PingdomEligibility
    include EnvironmentCheck
    attr_reader :publish_service

    def initialize(publish_service)
      @publish_service = publish_service
    end

    def can_create?
      allowed_environments? && uptime_check_count.zero?
    end

    def can_destroy?
      allowed_environments? && uptime_check_count.nonzero?
    end

    def cannot_create?
      !can_create?
    end

    def cannot_destroy?
      !can_destroy?
    end

    private

    def allowed_environments?
      live_production?(deployment_environment: publish_service.deployment_environment)
    end

    def uptime_check_count
      UptimeCheck.where(service_id: publish_service.service_id).count
    end
  end
end
