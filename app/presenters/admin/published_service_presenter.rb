module Admin
  class PublishedServicePresenter
    ENVIRONMENT_LABELS = {
      'production' => 'Live',
      'dev' => 'Test'
    }.freeze

    attr_reader :publish_service

    delegate :service_id, :deployment_environment, :user, :updated_at, to: :publish_service

    def initialize(publish_service)
      @publish_service = publish_service
    end

    def environment_label
      ENVIRONMENT_LABELS.fetch(deployment_environment, deployment_environment)
    end

    def status
      return publish_service.status.humanize unless publish_service.completed?

      maintenance_mode? ? 'Maintenance mode' : 'Published'
    end

    def status_modifier
      status.parameterize
    end

    private

    def maintenance_mode?
      ServiceConfiguration.exists?(
        service_id:,
        deployment_environment:,
        name: 'MAINTENANCE_MODE'
      )
    end
  end
end
