module Admin
  class ServicesController < Admin::ApplicationController
    def index
      response = MetadataApiClient::Service.all_services(
        page: page,
        per_page: per_page
      )

      @services = Kaminari.paginate_array(
        response[:services],
        total_count: response[:total_services]
      ).page(page).per(per_page)
    end

    def show
      @latest_metadata = MetadataApiClient::Service.latest_version(params[:id])
      @service = MetadataPresenter::Service.new(@latest_metadata, editor: true)
      @service_creator = User.find(@service.created_by)
      @version_creator = version_creator(@service_creator, @latest_metadata)
      @published_to_live = published(@service.service_id, 'production')
      @published_to_test = published(@service.service_id, 'dev')
      @versions = MetadataApiClient::Version.all(@service.service_id)
    end

    def search_term
      params[:search] || ''
    end
    helper_method :search_term

    private

    def version_creator(service_creator, latest_metadata)
      if service_creator.id == latest_metadata['created_by']
        service_creator
      else
        User.find(latest_metadata['created_by'])
      end
    end

    def page
      @page ||= params[:page] || 1
    end

    def per_page
      params[:per_page] || 20
    end
  end
end
