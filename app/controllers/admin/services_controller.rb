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

    def search_term
      params[:search] || ''
    end
    helper_method :search_term

    private

    def page
      @page ||= params[:page] || 1
    end

    def per_page
      params[:per_page] || 20
    end
  end
end
