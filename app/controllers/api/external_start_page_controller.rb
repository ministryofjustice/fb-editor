module Api
  class ExternalStartPageController < ApiController
    def show
      @external_url = external_url

      render @external_url, layout: false
    end

    def create
      external_url.url = external_url_params['external_start_page_url']['url']
      if external_url.valid?
        external_url_config = ServiceConfiguration.find_or_initialize_by(
          service_id: external_url_params['service_id'],
          deployment_environment: 'production',
          name: 'EXTERNAL_START_PAGE_URL'
        )

        external_url_config.value = external_url.url
        if external_url_config.save!
          redirect_to edit_service_path(external_url_params['service_id'])
        else
          render external_url, layout: false, status: :unprocessable_entity
        end
      else
        render external_url, layout: false, status: :unprocessable_entity
      end
    end

    def destroy
      external_url_config = ServiceConfiguration.find_by(
        service_id:,
        deployment_environment: 'production',
        name: 'EXTERNAL_START_PAGE_URL'
      )

      if external_url_config.present?
        if external_url_config.delete!
          render external_url, layout: false
        else
          render external_url, layout: false, status: :unprocessable_entity
        end
      else
        render external_url, layout: false, status: :not_found
      end
    end

    def external_url
      @external_url ||= ExternalStartPageUrl.new
    end

    def external_url_params
      params.permit(
        :authenticity_token,
        { external_start_page_url: %i[url] },
        :service_id,
      )
    end
  end
end