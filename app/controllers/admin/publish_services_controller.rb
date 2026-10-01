module Admin
  class PublishServicesController < Admin::ApplicationController
    ENVIRONMENTS = %w[production dev].freeze
    PER_PAGE = 20

    def index
      @environment = requested_environment
      @publish_services = current_state.page(params[:page]).per(PER_PAGE)
    end

    private

    def requested_environment
      ENVIRONMENTS.include?(params[:deployment_environment]) ? params[:deployment_environment] : 'production'
    end

    def current_state
      latest_publish_ids_per_service = PublishService
        .where(deployment_environment: @environment)
        .select('MAX(id) AS id')
        .group(:service_id)

      PublishService.where(id: latest_publish_ids_per_service)
                    .order(created_at: :desc, id: :desc)
    end
  end
end
