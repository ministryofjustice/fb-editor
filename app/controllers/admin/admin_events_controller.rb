module Admin
  class AdminEventsController < Admin::ApplicationController
    PER_PAGE = 50

    def index
      @admin_events = AdminEvent.recent
                                .includes(:user)
                                .page(params[:page])
                                .per(PER_PAGE)
      @service_names = service_names_for(@admin_events)
    end

    private

    def service_names_for(admin_events)
      admin_events.map(&:service_id).compact.uniq.index_with do |service_id|
        MetadataApiClient::Service.latest_version(service_id)['service_name']
      rescue Faraday::Error
        nil
      end
    end
  end
end
